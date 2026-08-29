# Install Alula without the script

Use this if you do not want to run `install.ps1`. Same result: AutoHotkey runs `Alula.ahk`, and your tablet buttons send 4th/5th click.

## 1. Install AutoHotkey v2

1. Open [https://www.autohotkey.com/](https://www.autohotkey.com/).
2. Download **AutoHotkey v2** and install it (64-bit is fine).
3. Leave the default install location unless you know you need something else.

You do **not** need AutoHotkey v1.

## 2. Keep this folder

Put the Alula folder somewhere you will not delete, for example:

`C:\Users\<you>\Documents\GitHub\Alula`

If `config.ini` is missing, copy `config.example.ini` and rename the copy to `config.ini`.

## 3. Map the pen (or mouse) buttons

Alula only sees **4th click** and **5th click**. The tablet maker’s software has to send those.

### Wacom Center

1. Open **Wacom Center**.
2. Select the tablet → **Pen**.
3. **Rear / second** barrel button → **4th click** (sometimes called Back).
4. **Front / first** barrel button → **5th click** (sometimes called Forward).
5. Do not use Right click, Pan/Zoom, or Keystroke for these two.

### Other tablets or a mouse

In that device’s software (or Windows mouse settings), map two buttons to **Back** and **Forward** (mouse button 4 and 5). Rear → 4th, front → 5th, unless you change `Trigger` / `SampleTrigger` in `config.ini`.

## 4. Start Alula

Double-click `Alula.ahk`.

Windows may ask what app to use the first time: choose **AutoHotkey 64-bit**.

You should get a tray icon (near the clock). If it is hidden, click the chevron (^) in the notification area.

## 5. Optional: start with Windows

1. Press `Win + R`, type `shell:startup`, press Enter.
2. Right-click in that folder → **New** → **Shortcut**.
3. Browse to `AutoHotkey64.exe` (often  
   `C:\Users\<you>\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe`  
   or `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`).
4. After the path, add a space and the full path to `Alula.ahk` in quotes, for example:

```
"C:\Users\OvO\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe" "C:\Users\OvO\Documents\GitHub\Alula\Alula.ahk"
```

5. Name the shortcut **Alula**.

Alternatively, start Alula once, then right-click the tray icon and enable **Run at Windows startup**.

## 6. Check in Krita

- Rear hold + drag → zoom
- Rear double-click hold + drag → pan
- Front click → undo
- Front hold over a colour → sample

If nothing happens, the tablet is probably still sending Right click instead of 4th/5th click. Recheck step 3.

More detail: [usage.md](usage.md), [config.md](config.md).
