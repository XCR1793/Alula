#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
InstallMouseHook
InstallKeybdHook
SendMode "Input"

; Alula — extra control on a pen’s barrel buttons (the alula is a bird’s “thumb”).
; Rear button: click-hold zoom, double-click-hold pan (Trigger = 4th click).
; Front button: click undo, hold colour sample (SampleTrigger = 5th click).

configPath := A_ScriptDir "\config.ini"
trigger := "XButton1"
sampleTrigger := "XButton2"
onlyKrita := true
clickHold := "zoom"
doubleClickMs := 280
sampleHoldMs := 180
showHint := true

state := "idle"
triggerHeld := false
armedAt := 0
downAt := 0
currentAction := ""
hotkeysBound := false

sampleState := "idle"
sampleHeld := false

LoadConfig()
SetupTray()
ApplyHotkeys()
OnExit(OnScriptExit)
SetTimer(WatchFocus, 100)

LoadConfig() {
    global configPath, trigger, sampleTrigger, onlyKrita, clickHold, doubleClickMs, sampleHoldMs, showHint
    examplePath := A_ScriptDir "\config.example.ini"
    if !FileExist(configPath) && FileExist(examplePath)
        FileCopy(examplePath, configPath)
    if !FileExist(configPath) {
        SaveConfig()
        return
    }
    trigger := IniRead(configPath, "General", "Trigger", "XButton1")
    sampleTrigger := IniRead(configPath, "General", "SampleTrigger", "XButton2")
    onlyKrita := IniRead(configPath, "General", "OnlyKrita", "1") = "1"
    clickHold := StrLower(IniRead(configPath, "General", "ClickHold", "zoom"))
    if clickHold != "zoom" && clickHold != "pan"
        clickHold := "zoom"
    doubleClickMs := Integer(IniRead(configPath, "General", "DoubleClickMs", "280"))
    sampleHoldMs := Integer(IniRead(configPath, "General", "SampleHoldMs", "180"))
    showHint := IniRead(configPath, "General", "ShowHint", "1") = "1"
}

SaveConfig() {
    global configPath, trigger, sampleTrigger, onlyKrita, clickHold, doubleClickMs, sampleHoldMs, showHint
    IniWrite(trigger, configPath, "General", "Trigger")
    IniWrite(sampleTrigger, configPath, "General", "SampleTrigger")
    IniWrite(onlyKrita ? "1" : "0", configPath, "General", "OnlyKrita")
    IniWrite(clickHold, configPath, "General", "ClickHold")
    IniWrite(doubleClickMs, configPath, "General", "DoubleClickMs")
    IniWrite(sampleHoldMs, configPath, "General", "SampleHoldMs")
    IniWrite(showHint ? "1" : "0", configPath, "General", "ShowHint")
}

ShouldHandle(*) {
    global onlyKrita, triggerHeld, currentAction, sampleHeld, sampleState
    if triggerHeld || currentAction != "" || sampleHeld || sampleState != "idle"
        return true
    return !onlyKrita || WinActive("ahk_exe krita.exe")
}

ApplyHotkeys() {
    global trigger, sampleTrigger, hotkeysBound
    HotIf ShouldHandle
    try Hotkey("*" trigger, OnTriggerDown, "On")
    try Hotkey("*" trigger " up", OnTriggerUp, "On")
    try Hotkey("*" sampleTrigger, OnSampleDown, "On")
    try Hotkey("*" sampleTrigger " up", OnSampleUp, "On")
    HotIf()
    hotkeysBound := true
}

OnTriggerDown(*) {
    global state, triggerHeld, armedAt, downAt, doubleClickMs
    triggerHeld := true
    downAt := A_TickCount
    if state = "armed" && (A_TickCount - armedAt) <= doubleClickMs {
        SetTimer(ClearArmed, 0)
        state := "doubleHold"
        StartNav(OtherAction())
        return
    }
    state := "singleHold"
    StartNav(ClickHoldAction())
}

OnTriggerUp(*) {
    global state, triggerHeld, armedAt, downAt, doubleClickMs
    triggerHeld := false
    if state = "singleHold" {
        wasTap := (A_TickCount - downAt) <= doubleClickMs
        ReleaseNav()
        if wasTap {
            state := "armed"
            armedAt := A_TickCount
            SetTimer(ClearArmed, -doubleClickMs)
        } else
            state := "idle"
        return
    }
    if state = "doubleHold" {
        ReleaseNav()
        state := "idle"
    }
}

ClearArmed() {
    global state
    if state = "armed"
        state := "idle"
}

ClickHoldAction() {
    global clickHold
    return clickHold
}

OtherAction() {
    global clickHold
    return clickHold = "zoom" ? "pan" : "zoom"
}

StartNav(action) {
    global currentAction
    ReleaseNav()
    if action = "zoom"
        Send("{LCtrl down}{Space down}")
    else
        Send("{Space down}")
    currentAction := action
    Hint(StrUpper(action))
}

ReleaseNav() {
    global currentAction
    if currentAction = "zoom"
        Send("{Space up}{LCtrl up}")
    else if currentAction = "pan"
        Send("{Space up}")
    currentAction := ""
    ToolTip()
}

OnSampleDown(*) {
    global sampleState, sampleHeld, sampleHoldMs
    sampleHeld := true
    sampleState := "pending"
    SetTimer(BeginSample, -sampleHoldMs)
}

OnSampleUp(*) {
    global sampleState, sampleHeld
    sampleHeld := false
    SetTimer(BeginSample, 0)
    if sampleState = "pending" {
        sampleState := "idle"
        Send("^z")
        Hint("UNDO")
        return
    }
    if sampleState = "sampling"
        ReleaseSample()
}

BeginSample() {
    global sampleState, sampleHeld
    if sampleState != "pending" || !sampleHeld
        return
    sampleState := "sampling"
    Send("{LCtrl down}")
    Click("left")
    Hint("SAMPLE")
}

ReleaseSample() {
    global sampleState
    if sampleState = "sampling"
        Send("{LCtrl up}")
    sampleState := "idle"
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
    SetTimer(BeginSample, 0)
    ReleaseNav()
    ReleaseSample()
}

OnScriptExit(*) {
    ReleaseAll()
}

WatchFocus() {
    global onlyKrita, currentAction, state, triggerHeld, sampleState
    if onlyKrita && !WinActive("ahk_exe krita.exe") {
        if currentAction != "" {
            ReleaseNav()
            if !triggerHeld
                state := "idle"
        }
        if sampleState = "sampling" || sampleState = "pending"
            ReleaseSample()
    }
}

SetupTray() {
    A_IconTip := "Alula"
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Alula", (*) => 0)
    A_TrayMenu.Disable("Alula")
    A_TrayMenu.Add()
    A_TrayMenu.Add("Click-hold = Zoom,  double-hold = Pan", SetZoomFirst)
    A_TrayMenu.Add("Click-hold = Pan,  double-hold = Zoom", SetPanFirst)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Only while Krita is focused", ToggleOnlyKrita)
    A_TrayMenu.Add("Show ZOOM / PAN hint", ToggleHint)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Open config.ini", (*) => Run('notepad.exe "' configPath '"'))
    A_TrayMenu.Add("Reload", (*) => Reload())
    A_TrayMenu.Add("Release stuck keys", (*) => ReleaseAll())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Run at Windows startup", ToggleStartup)
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    RefreshTray()
}

SetZoomFirst(*) {
    global clickHold
    clickHold := "zoom"
    SaveConfig()
    RefreshTray()
}

SetPanFirst(*) {
    global clickHold
    clickHold := "pan"
    SaveConfig()
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
    global clickHold, onlyKrita, showHint
    A_TrayMenu.Uncheck("Click-hold = Zoom,  double-hold = Pan")
    A_TrayMenu.Uncheck("Click-hold = Pan,  double-hold = Zoom")
    if clickHold = "zoom"
        A_TrayMenu.Check("Click-hold = Zoom,  double-hold = Pan")
    else
        A_TrayMenu.Check("Click-hold = Pan,  double-hold = Zoom")
    if onlyKrita
        A_TrayMenu.Check("Only while Krita is focused")
    else
        A_TrayMenu.Uncheck("Only while Krita is focused")
    if showHint
        A_TrayMenu.Check("Show ZOOM / PAN hint")
    else
        A_TrayMenu.Uncheck("Show ZOOM / PAN hint")
    if IsStartupEnabled()
        A_TrayMenu.Check("Run at Windows startup")
    else
        A_TrayMenu.Uncheck("Run at Windows startup")
    A_IconTip := "Alula`nRear: click-hold " StrUpper(clickHold) " / double-hold " StrUpper(OtherAction()) "`nFront: click Undo / hold Sample"
}
