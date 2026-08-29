# Using Alula

Alula runs in the background. It only remaps buttons while **Krita** is focused, unless you turn that off in the tray or in `config.ini`.

## Rear button (4th click)

| Gesture | Default |
| --- | --- |
| Press and **hold**, then drag | Zoom |
| **Click, click again and hold**, then drag | Pan |

Zoom starts the moment the button goes down. The first tap of a double-click may flash zoom for a split second, then pan takes over.

Swap zoom and pan: tray icon → **Click-hold = Pan, double-hold = Zoom**.

## Front button (5th click)

| Gesture | Default |
| --- | --- |
| Short **click** | Undo |
| **Hold** over a colour | Sample that pixel |

Keep holding after a sample and tap other spots to pick more colours. Hold is detected after about 180 ms so a click is not also a sample.

## Tray menu

Right-click the Alula icon (notification area):

- Swap rear-button zoom / pan
- **Only while Krita is focused**
- Show or hide the on-screen ZOOM / PAN / UNDO / SAMPLE hint
- Open `config.ini`
- Reload after you edit config
- **Release stuck keys** if Ctrl or Space gets stuck
- **Run at Windows startup**
- Exit

## Krita shortcuts Alula expects

These are Krita’s usual canvas shortcuts. If you changed them, either change Krita back or Alula will feel wrong.

| Action | Keys |
| --- | --- |
| Pan | `Space` + drag |
| Zoom | `Ctrl+Space` + drag |
| Undo | `Ctrl+Z` |
| Colour sample | `Ctrl` + click |

Check: **Settings → Configure Krita → Canvas Input Settings**.

If you use a Photoshop-compatible input profile, colour pick may be **Alt** instead of **Ctrl**. Sampling will not work until that matches.

## Other apps

Alula is not Wacom-specific. Any device that can emit 4th and 5th click works. The *actions* are Krita keystrokes. To use another app, turn off “only Krita” and be aware Space / Ctrl+Space / Ctrl+Z will fire there too.
