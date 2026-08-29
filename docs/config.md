# Config

Alula reads `config.ini` next to `Alula.ahk`. If that file is missing, it copies `config.example.ini`.

The usual way to change mappings is **tray → Settings**. That window writes this file. After editing by hand, tray → **Reload**.

## General

| Key | Default | Meaning |
| --- | --- | --- |
| `OnlyKrita` | `1` | Ignore the buttons unless Krita is focused. |
| `DoubleClickMs` | `280` | Window for a second press to count as double-click / double-hold. |
| `HoldMs` | `180` | How long a press must last to count as a hold, **when a click gesture is also enabled** on that button. |
| `ShowHint` | `1` | Brief tooltip (ZOOM, UNDO, …). |

## Per button (`[XButton1]` and `[XButton2]`)

Each button has four gestures. A gesture does nothing until it is enabled (`1`), then it uses the matching `*Action`.

| Key | Default 4th | Default 5th | Meaning |
| --- | --- | --- | --- |
| `SingleClick` | `0` | `1` | Enable single click. |
| `SingleClickAction` | `default` | `undo` | `default` (Back/Forward), `undo`, `redo`, `sample` |
| `DoubleClick` | `0` | `0` | Enable double click. |
| `DoubleClickAction` | `default` | `default` | Same click actions. |
| `Hold` | `1` | `1` | Enable click-and-hold. |
| `HoldAction` | `zoom` | `sample` | `zoom`, `pan`, `sample` |
| `DoubleHold` | `1` | `0` | Enable double-click-and-hold. |
| `DoubleHoldAction` | `pan` | `zoom` | Same hold actions. |

`default` on a click sends the real 4th/5th mouse button (browser Back / Forward).

## Timing

Alula only waits when it must tell two **enabled** gestures apart:

- Hold enabled, single and double click **off** → hold starts the instant the button goes down (4th-click zoom).
- Single click **and** hold enabled → wait `HoldMs` (5th-click undo vs sample).
- Double click or double-hold enabled → wait `DoubleClickMs` after a short tap for a second press.

## Pass-through profile

Settings → **Pass-through only** turns off every gesture except single click = Default (Back/Forward) on both buttons.
