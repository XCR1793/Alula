#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
InstallMouseHook
InstallKeybdHook
SendMode "Input"

; Alula — four gestures per 4th/5th mouse button, assigned in tray → Settings.

configPath := A_ScriptDir "\config.ini"
onlyKrita := true
doubleClickMs := 280
holdMs := 180
showHint := true

clickActions := ["default", "undo", "redo", "sample"]
holdActions := ["zoom", "pan", "sample"]
clickLabels := ["Default (Back/Forward)", "Undo", "Redo", "Sample"]
holdLabels := ["Zoom", "Pan", "Sample"]

buttons := Map()
runtime := Map()
heldFn := ""
passThrough := false
settingsGui := 0
settingsCtrl := Map()

LoadConfig()
InitRuntime()
SetupTray()
ApplyHotkeys()
OnExit(OnScriptExit)
SetTimer(WatchFocus, 100)

AlulaDefaults() {
    return Map(
        "XButton1", Map(
            "single", Map("on", false, "fn", "default"),
            "double", Map("on", false, "fn", "default"),
            "hold", Map("on", true, "fn", "zoom"),
            "doubleHold", Map("on", true, "fn", "pan")
        ),
        "XButton2", Map(
            "single", Map("on", true, "fn", "undo"),
            "double", Map("on", false, "fn", "default"),
            "hold", Map("on", true, "fn", "sample"),
            "doubleHold", Map("on", false, "fn", "zoom")
        )
    )
}

PassThroughDefaults() {
    d := AlulaDefaults()
    for btn, _ in d {
        d[btn]["single"]["on"] := true
        d[btn]["single"]["fn"] := "default"
        d[btn]["double"]["on"] := false
        d[btn]["hold"]["on"] := false
        d[btn]["doubleHold"]["on"] := false
    }
    return d
}

NormClick(fn) {
    global clickActions
    fn := StrLower(fn)
    for a in clickActions
        if a = fn
            return fn
    return "default"
}

NormHold(fn) {
    global holdActions
    fn := StrLower(fn)
    for a in holdActions
        if a = fn
            return fn
    return "zoom"
}

IniOn(section, key, fallback) {
    global configPath
    return IniRead(configPath, section, key, fallback) = "1"
}

LoadConfig() {
    global configPath, onlyKrita, doubleClickMs, holdMs, showHint, buttons
    examplePath := A_ScriptDir "\config.example.ini"
    if !FileExist(configPath) && FileExist(examplePath)
        FileCopy(examplePath, configPath)
    if !FileExist(configPath) {
        buttons := AlulaDefaults()
        SaveConfig()
        return
    }
    if IniRead(configPath, "General", "ClickHold", "") != ""
        MigrateOldConfig()
    onlyKrita := IniRead(configPath, "General", "OnlyKrita", "1") = "1"
    doubleClickMs := Integer(IniRead(configPath, "General", "DoubleClickMs", "280"))
    holdMs := Integer(IniRead(configPath, "General", "HoldMs", IniRead(configPath, "General", "SampleHoldMs", "180")))
    showHint := IniRead(configPath, "General", "ShowHint", "1") = "1"
    buttons := AlulaDefaults()
    for btn in ["XButton1", "XButton2"] {
        buttons[btn]["single"]["on"] := IniOn(btn, "SingleClick", buttons[btn]["single"]["on"] ? "1" : "0")
        buttons[btn]["single"]["fn"] := NormClick(IniRead(configPath, btn, "SingleClickAction", "default"))
        buttons[btn]["double"]["on"] := IniOn(btn, "DoubleClick", "0")
        buttons[btn]["double"]["fn"] := NormClick(IniRead(configPath, btn, "DoubleClickAction", "default"))
        buttons[btn]["hold"]["on"] := IniOn(btn, "Hold", buttons[btn]["hold"]["on"] ? "1" : "0")
        buttons[btn]["hold"]["fn"] := NormHold(IniRead(configPath, btn, "HoldAction", "zoom"))
        buttons[btn]["doubleHold"]["on"] := IniOn(btn, "DoubleHold", buttons[btn]["doubleHold"]["on"] ? "1" : "0")
        buttons[btn]["doubleHold"]["fn"] := NormHold(IniRead(configPath, btn, "DoubleHoldAction", "pan"))
    }
}

MigrateOldConfig() {
    global configPath
    clickHold := StrLower(IniRead(configPath, "General", "ClickHold", "zoom"))
    if clickHold != "zoom" && clickHold != "pan"
        clickHold := "zoom"
    other := clickHold = "zoom" ? "pan" : "zoom"
    IniDelete(configPath, "General", "Trigger")
    IniDelete(configPath, "General", "SampleTrigger")
    IniDelete(configPath, "General", "ClickHold")
    IniDelete(configPath, "General", "SampleHoldMs")
    buttons := AlulaDefaults()
    buttons["XButton1"]["hold"]["fn"] := clickHold
    buttons["XButton1"]["doubleHold"]["fn"] := other
    SaveButtons(buttons)
}

SaveButtons(btns) {
    global configPath
    for btn, g in btns {
        IniWrite(g["single"]["on"] ? "1" : "0", configPath, btn, "SingleClick")
        IniWrite(g["single"]["fn"], configPath, btn, "SingleClickAction")
        IniWrite(g["double"]["on"] ? "1" : "0", configPath, btn, "DoubleClick")
        IniWrite(g["double"]["fn"], configPath, btn, "DoubleClickAction")
        IniWrite(g["hold"]["on"] ? "1" : "0", configPath, btn, "Hold")
        IniWrite(g["hold"]["fn"], configPath, btn, "HoldAction")
        IniWrite(g["doubleHold"]["on"] ? "1" : "0", configPath, btn, "DoubleHold")
        IniWrite(g["doubleHold"]["fn"], configPath, btn, "DoubleHoldAction")
    }
}

SaveConfig() {
    global configPath, onlyKrita, doubleClickMs, holdMs, showHint, buttons
    IniWrite(onlyKrita ? "1" : "0", configPath, "General", "OnlyKrita")
    IniWrite(doubleClickMs, configPath, "General", "DoubleClickMs")
    IniWrite(holdMs, configPath, "General", "HoldMs")
    IniWrite(showHint ? "1" : "0", configPath, "General", "ShowHint")
    SaveButtons(buttons)
}

InitRuntime() {
    global runtime
    runtime := Map()
    for btn in ["XButton1", "XButton2"] {
        runtime[btn] := Map(
            "state", "idle",
            "held", false,
            "downAt", 0,
            "holdCb", HoldTimer.Bind(btn),
            "dblHoldCb", DoubleHoldTimer.Bind(btn),
            "armedCb", ArmedTimer.Bind(btn)
        )
    }
}

On(btn, gesture) {
    global buttons
    return buttons[btn][gesture]["on"]
}

Fn(btn, gesture) {
    global buttons
    return buttons[btn][gesture]["fn"]
}

ImmediateHold(btn) {
    return On(btn, "hold") && !On(btn, "single") && !On(btn, "double")
}

ImmediateDoubleHold(btn) {
    return On(btn, "doubleHold") && !On(btn, "double")
}

WantsDouble(btn) {
    return On(btn, "double") || On(btn, "doubleHold")
}

ShouldHandle(*) {
    global onlyKrita, runtime, heldFn
    if heldFn != ""
        return true
    for btn, rt in runtime
        if rt["held"] || rt["state"] != "idle"
            return true
    return !onlyKrita || WinActive("ahk_exe krita.exe")
}

ApplyHotkeys() {
    HotIf ShouldHandle
    Hotkey("*XButton1", OnDown.Bind("XButton1"), "On")
    Hotkey("*XButton1 up", OnUp.Bind("XButton1"), "On")
    Hotkey("*XButton2", OnDown.Bind("XButton2"), "On")
    Hotkey("*XButton2 up", OnUp.Bind("XButton2"), "On")
    HotIf()
}

CancelTimers(btn) {
    global runtime
    rt := runtime[btn]
    SetTimer(rt["holdCb"], 0)
    SetTimer(rt["dblHoldCb"], 0)
    SetTimer(rt["armedCb"], 0)
}

OnDown(btn, *) {
    global passThrough, runtime, holdMs
    if passThrough
        return
    rt := runtime[btn]
    rt["held"] := true
    rt["downAt"] := A_TickCount
    if rt["state"] = "armed" {
        CancelTimers(btn)
        rt["state"] := "down2"
        if ImmediateDoubleHold(btn)
            BeginHold(btn, Fn(btn, "doubleHold"), "doubleHold")
        else if On(btn, "doubleHold")
            SetTimer(rt["dblHoldCb"], -holdMs)
        return
    }
    CancelTimers(btn)
    rt["state"] := "down1"
    if ImmediateHold(btn)
        BeginHold(btn, Fn(btn, "hold"), "hold")
    else if On(btn, "hold")
        SetTimer(rt["holdCb"], -holdMs)
}

OnUp(btn, *) {
    global passThrough, runtime, doubleClickMs
    if passThrough
        return
    rt := runtime[btn]
    rt["held"] := false
    CancelTimers(btn)
    switch rt["state"] {
        case "holding":
            EndHold()
            if WantsDouble(btn) && (A_TickCount - rt["downAt"] <= doubleClickMs) {
                rt["state"] := "armed"
                SetTimer(rt["armedCb"], -doubleClickMs)
            } else
                rt["state"] := "idle"
        case "doubleHolding":
            EndHold()
            rt["state"] := "idle"
        case "down1":
            if WantsDouble(btn) {
                rt["state"] := "armed"
                SetTimer(rt["armedCb"], -doubleClickMs)
            } else {
                rt["state"] := "idle"
                if On(btn, "single")
                    FireClick(btn, Fn(btn, "single"))
            }
        case "down2":
            rt["state"] := "idle"
            if On(btn, "double")
                FireClick(btn, Fn(btn, "double"))
        default:
            rt["state"] := "idle"
    }
}

HoldTimer(btn) {
    global runtime
    rt := runtime[btn]
    if rt["state"] = "down1" && rt["held"]
        BeginHold(btn, Fn(btn, "hold"), "hold")
}

DoubleHoldTimer(btn) {
    global runtime
    rt := runtime[btn]
    if rt["state"] = "down2" && rt["held"]
        BeginHold(btn, Fn(btn, "doubleHold"), "doubleHold")
}

ArmedTimer(btn) {
    global runtime
    rt := runtime[btn]
    if rt["state"] != "armed"
        return
    rt["state"] := "idle"
    if On(btn, "single")
        FireClick(btn, Fn(btn, "single"))
}

BeginHold(btn, action, kind) {
    global runtime
    rt := runtime[btn]
    rt["state"] := kind = "doubleHold" ? "doubleHolding" : "holding"
    StartHold(action)
}

FireClick(btn, action) {
    switch action {
        case "undo":
            Send("^z")
            Hint("UNDO")
        case "redo":
            Send("^+z")
            Hint("REDO")
        case "sample":
            Send("{LCtrl down}")
            Click("left")
            Send("{LCtrl up}")
            Hint("SAMPLE")
        case "default":
            SendPass(btn)
            Hint(btn = "XButton1" ? "BACK" : "FORWARD")
    }
}

SendPass(btn) {
    global passThrough
    passThrough := true
    Send("{Blind}{" btn "}")
    passThrough := false
}

StartHold(action) {
    global heldFn
    EndHold()
    switch action {
        case "zoom":
            Send("{LCtrl down}{Space down}")
        case "pan":
            Send("{Space down}")
        case "sample":
            Send("{LCtrl down}")
            Click("left")
        default:
            return
    }
    heldFn := action
    Hint(StrUpper(action))
}

EndHold() {
    global heldFn
    switch heldFn {
        case "zoom":
            Send("{Space up}{LCtrl up}")
        case "pan":
            Send("{Space up}")
        case "sample":
            Send("{LCtrl up}")
    }
    heldFn := ""
    ToolTip()
}

Hint(text) {
    global showHint
    if showHint {
        ToolTip(text)
        SetTimer(() => ToolTip(), -700)
    }
}

ReleaseAll() {
    global runtime
    for btn, rt in runtime {
        CancelTimers(btn)
        rt["held"] := false
        rt["state"] := "idle"
    }
    EndHold()
}

OnScriptExit(*) {
    ReleaseAll()
}

WatchFocus() {
    global onlyKrita, heldFn
    if !onlyKrita || WinActive("ahk_exe krita.exe")
        return
    if heldFn != "" || ButtonBusy()
        ReleaseAll()
}

ButtonBusy() {
    global runtime
    for btn, rt in runtime
        if rt["held"] || rt["state"] != "idle"
            return true
    return false
}

SetupTray() {
    A_IconTip := "Alula"
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Alula", (*) => 0)
    A_TrayMenu.Disable("Alula")
    A_TrayMenu.Add()
    A_TrayMenu.Add("Settings...", OpenSettings)
    A_TrayMenu.Default := "Settings..."
    A_TrayMenu.Add()
    A_TrayMenu.Add("Only while Krita is focused", ToggleOnlyKrita)
    A_TrayMenu.Add("Show hints", ToggleHint)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Open config.ini", (*) => Run('notepad.exe "' configPath '"'))
    A_TrayMenu.Add("Reload", (*) => Reload())
    A_TrayMenu.Add("Release stuck keys", (*) => ReleaseAll())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Run at Windows startup", ToggleStartup)
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    RefreshTray()
}

ToggleOnlyKrita(*) {
    global onlyKrita
    onlyKrita := !onlyKrita
    SaveConfig()
    RefreshTray()
}

ToggleHint(*) {
    global showHint
    showHint := !showHint
    SaveConfig()
    RefreshTray()
}

StartupShortcut() {
    return A_Startup "\Alula.lnk"
}

IsStartupEnabled() {
    return FileExist(StartupShortcut())
}

ToggleStartup(*) {
    link := StartupShortcut()
    if FileExist(link)
        FileDelete(link)
    else
        FileCreateShortcut(A_AhkPath, link, A_ScriptDir, '"' A_ScriptFullPath '"', "Alula pen button helper")
    RefreshTray()
}

RefreshTray() {
    global onlyKrita, showHint, buttons
    if onlyKrita
        A_TrayMenu.Check("Only while Krita is focused")
    else
        A_TrayMenu.Uncheck("Only while Krita is focused")
    if showHint
        A_TrayMenu.Check("Show hints")
    else
        A_TrayMenu.Uncheck("Show hints")
    if IsStartupEnabled()
        A_TrayMenu.Check("Run at Windows startup")
    else
        A_TrayMenu.Uncheck("Run at Windows startup")
    A_IconTip := "Alula`n4th: " GestureTip(buttons["XButton1"]) "`n5th: " GestureTip(buttons["XButton2"]) "`nDouble-click for settings"
}

GestureTip(g) {
    parts := []
    if g["single"]["on"]
        parts.Push("click " g["single"]["fn"])
    if g["double"]["on"]
        parts.Push("dbl " g["double"]["fn"])
    if g["hold"]["on"]
        parts.Push("hold " g["hold"]["fn"])
    if g["doubleHold"]["on"]
        parts.Push("dbl-hold " g["doubleHold"]["fn"])
    return parts.Length ? StrJoin(parts, " / ") : "off"
}

StrJoin(arr, sep) {
    out := ""
    for v in arr
        out .= (out = "" ? "" : sep) v
    return out
}

IndexOf(list, value) {
    for i, v in list
        if v = value
            return i
    return 1
}

OpenSettings(*) {
    global settingsGui, settingsCtrl, buttons, onlyKrita, showHint, doubleClickMs, holdMs
    if settingsGui {
        FillSettings(buttons)
        settingsCtrl["doubleMs"].Value := doubleClickMs
        settingsCtrl["holdMs"].Value := holdMs
        settingsCtrl["krita"].Value := onlyKrita
        settingsCtrl["hint"].Value := showHint
        settingsGui.Show()
        return
    }
    g := Gui("+OwnDialogs", "Alula settings")
    g.SetFont("s9", "Segoe UI")
    g.AddText("w560", "Each 4th/5th-click button has four gestures. Leave a box unchecked to ignore that gesture. Enable it, then assign a function.")
    settingsCtrl := Map()
    AddButtonColumn(g, "xm ym+40", "4th click (Back)", "XButton1")
    AddButtonColumn(g, "x+16 ym+40", "5th click (Forward)", "XButton2")
    g.AddText("xm y+18", "Double-click window (ms)")
    settingsCtrl["doubleMs"] := g.AddEdit("x+8 yp-3 w50 Number", doubleClickMs)
    g.AddText("x+16 yp+3", "Hold threshold (ms)")
    settingsCtrl["holdMs"] := g.AddEdit("x+8 yp-3 w50 Number", holdMs)
    settingsCtrl["krita"] := g.AddCheckbox("xm y+12", "Only while Krita is focused")
    settingsCtrl["hint"] := g.AddCheckbox("x+16 yp", "Show ZOOM / UNDO hints")
    g.AddButton("xm y+16 w120", "Alula defaults").OnEvent("Click", (*) => FillSettings(AlulaDefaults()))
    g.AddButton("x+8 w150", "Pass-through only").OnEvent("Click", (*) => FillSettings(PassThroughDefaults()))
    g.AddButton("x+16 w90 Default", "Save").OnEvent("Click", SaveSettings)
    g.AddButton("x+8 w90", "Cancel").OnEvent("Click", (*) => settingsGui.Hide())
    g.OnEvent("Close", (*) => settingsGui.Hide())
    settingsGui := g
    settingsCtrl["krita"].Value := onlyKrita
    settingsCtrl["hint"].Value := showHint
    FillSettings(buttons)
    g.Show()
}

AddButtonColumn(g, pos, title, btn) {
    global settingsCtrl, clickLabels, holdLabels
    g.AddGroupBox(pos " Section w270 h178", title)
    rows := [
        ["single", "Single click", clickLabels],
        ["double", "Double click", clickLabels],
        ["hold", "Click and hold", holdLabels],
        ["doubleHold", "Double-click and hold", holdLabels]
    ]
    y := 28
    for row in rows {
        key := row[1]
        cb := g.AddCheckbox("xs+12 ys+" y " w128", row[2])
        dd := g.AddDropDownList("x+4 yp-3 w118", row[3])
        settingsCtrl[btn "|" key "|on"] := cb
        settingsCtrl[btn "|" key "|fn"] := dd
        cb.OnEvent("Click", UpdateSettingsEnabled.Bind())
        y += 34
    }
}

FillSettings(btns) {
    global settingsCtrl, clickActions, holdActions
    for btn in ["XButton1", "XButton2"] {
        for key in ["single", "double", "hold", "doubleHold"] {
            spec := btns[btn][key]
            settingsCtrl[btn "|" key "|on"].Value := spec["on"]
            list := (key = "hold" || key = "doubleHold") ? holdActions : clickActions
            settingsCtrl[btn "|" key "|fn"].Value := IndexOf(list, spec["fn"])
        }
    }
    UpdateSettingsEnabled()
}

UpdateSettingsEnabled(*) {
    global settingsCtrl
    for btn in ["XButton1", "XButton2"] {
        for key in ["single", "double", "hold", "doubleHold"] {
            on := settingsCtrl[btn "|" key "|on"].Value
            settingsCtrl[btn "|" key "|fn"].Enabled := !!on
        }
    }
}

ReadSettingsButtons() {
    global settingsCtrl, clickActions, holdActions
    out := Map()
    for btn in ["XButton1", "XButton2"] {
        out[btn] := Map()
        for key in ["single", "double", "hold", "doubleHold"] {
            list := (key = "hold" || key = "doubleHold") ? holdActions : clickActions
            idx := Integer(settingsCtrl[btn "|" key "|fn"].Value)
            if idx < 1
                idx := 1
            out[btn][key] := Map(
                "on", !!settingsCtrl[btn "|" key "|on"].Value,
                "fn", list[idx]
            )
        }
    }
    return out
}

SaveSettings(*) {
    global settingsGui, settingsCtrl, buttons, onlyKrita, showHint, doubleClickMs, holdMs
    buttons := ReadSettingsButtons()
    onlyKrita := !!settingsCtrl["krita"].Value
    showHint := !!settingsCtrl["hint"].Value
    doubleClickMs := Integer(settingsCtrl["doubleMs"].Value)
    holdMs := Integer(settingsCtrl["holdMs"].Value)
    if doubleClickMs < 50
        doubleClickMs := 50
    if holdMs < 50
        holdMs := 50
    SaveConfig()
    settingsGui.Hide()
    RefreshTray()
}
