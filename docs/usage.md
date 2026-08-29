# Using Alula

Alula runs in the background. It only remaps buttons while **Krita** is focused, unless you turn that off.

## Default mapping (your current set)

| Button | Gesture | Action |
| --- | --- | --- |
| 4th click (rear) | Click and hold | Zoom |
| 4th click | Double-click and hold | Pan |
| 5th click (front) | Single click | Undo |
| 5th click | Click and hold | Sample colour |

Single click and double click on the 4th button are **off**. Double click and double-hold on the 5th button are **off**. Enable them in Settings if you want them.

Zoom on the rear button starts the moment you press (no wait), because click is not enabled on that button. Undo vs sample on the front button still needs a short hold threshold so a click is not also a sample.

## Settings (tray)

Right-click the Alula icon (notification area) → **Settings…**, or double-click the icon.

For each of **4th click** and **5th click**:

1. Tick a gesture to turn it on (single click, double click, click and hold, double-click and hold).
2. Pick a function from the list next to it.
3. **Save**.

Click functions: Default (Back/Forward), Undo, Redo, Sample.  
Hold functions: Zoom, Pan, Sample.

**Alula defaults** restores this Krita set. **Pass-through only** leaves only native Back/Forward on a single click.

## Tray menu

- **Settings…**
- **Only while Krita is focused**
- **Show hints**
- Open `config.ini` / Reload / Release stuck keys
- Run at Windows startup
- Exit

## Krita shortcuts Alula expects

| Action | Keys |
| --- | --- |
| Pan | `Space` + drag |
| Zoom | `Ctrl+Space` + drag |
| Undo | `Ctrl+Z` |
| Redo | `Ctrl+Shift+Z` |
| Colour sample | `Ctrl` + click |

**Settings → Configure Krita → Canvas Input Settings.** A Photoshop-compatible profile may use Alt for the picker instead of Ctrl.

## Other apps

Any device that can emit 4th and 5th click works. The functions are Krita keystrokes. Turn off “only Krita” if you want them elsewhere.
