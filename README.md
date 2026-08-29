# Alula

An extra control surface for a pen’s two barrel buttons — named after a bird’s **alula**, the small “thumb” on the wing.

Alula does not talk to a Wacom driver. It watches **4th click** and **5th click** (Back / Forward mouse buttons). Any tablet or mouse that can send those will work. Defaults are tuned for **Krita** on Windows.

| Button | Gesture | Action |
| --- | --- | --- |
| Rear (4th click) | Hold | Zoom (`Ctrl+Space` + drag) |
| Rear | Double-click and hold | Pan (`Space` + drag) |
| Front (5th click) | Click | Undo (`Ctrl+Z`) |
| Front | Hold | Sample colour (Krita Ctrl picker) |

## Install with the script

1. Clone or download this folder and keep it somewhere permanent (the startup shortcut points here).
2. In that folder, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

That installs AutoHotkey v2 if needed, starts Alula, and adds it to Windows startup.

3. Map the hardware buttons (once):

**Wacom Center** → your tablet → **Pen**

- Rear / second barrel button → **4th click** (Back)
- Front / first barrel button → **5th click** (Forward)

Do not leave them on Right click, Pan/Zoom, or a keystroke.

4. Open Krita. A tray icon named Alula should be near the clock.

To stop startup later: tray → **Run at Windows startup**, or run `uninstall.ps1`.

## Install without the script

Step-by-step (download AutoHotkey yourself, no PowerShell): **[docs/install-manual.md](docs/install-manual.md)**

## Docs

- **[How to use](docs/usage.md)** — gestures, tray menu, Krita shortcuts
- **[Config](docs/config.md)** — `config.ini` keys
- **[How it works](docs/how-it-works.md)** — why this is not a tablet driver plugin

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Removes the startup shortcut and stops Alula. It does not remove AutoHotkey.
