# Config

Alula reads `config.ini` next to `Alula.ahk`. If that file is missing, it copies `config.example.ini` (or writes built-in defaults).

Tray toggles write back into `config.ini`. After editing the file by hand, tray → **Reload**.

| Key | Default | Meaning |
| --- | --- | --- |
| `Trigger` | `XButton1` | Rear button. `XButton1` = 4th click / Back. |
| `SampleTrigger` | `XButton2` | Front button. `XButton2` = 5th click / Forward. |
| `OnlyKrita` | `1` | `1` = ignore the buttons unless Krita is focused. |
| `ClickHold` | `zoom` | Rear click-hold action. Other value: `pan`. Double-hold is the opposite. |
| `DoubleClickMs` | `280` | How long after a short rear tap a second press counts as double-hold. |
| `SampleHoldMs` | `180` | How long the front button must be held to sample instead of undo. |
| `ShowHint` | `1` | Brief tooltip: ZOOM, PAN, UNDO, SAMPLE. |

## Triggers

Use AutoHotkey mouse-button names:

- `XButton1` — 4th click (Back)
- `XButton2` — 5th click (Forward)
- `MButton` — middle click (only if you really want to steal it)

The tablet or mouse software must send that button. Alula cannot see a Wacom “Right click” or “Pan/Zoom” assignment.

## Timing

- **Rear hold** is immediate. `DoubleClickMs` only defines the double-click window.
- **Front click vs hold** cannot be immediate for both. Undo runs on release of a short press. Sample starts after `SampleHoldMs` while still held. Lower that number if sample feels late; raise it if undo keeps becoming a sample.
