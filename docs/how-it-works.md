# How Alula works

Tablet makers (Wacom included) assign **one** function per pen button. There is no official plugin that sits between the tablet and the driver to turn one button into click-hold vs double-click-hold.

Alula sits **after** the driver:

```
Pen button  →  tablet software  →  4th/5th mouse click  →  Alula  →  Krita keys
```

1. You map barrel buttons to **4th click** and **5th click** in Wacom Center (or Huion, XP-Pen, a mouse, etc.).
2. Windows sees normal mouse buttons `XButton1` and `XButton2`.
3. AutoHotkey (Alula) watches those buttons and holds Krita’s shortcuts for as long as you hold the pen button.

So it is **not** Wacom-specific. Anything that can generate 4th and 5th click can drive it. It is also **not** a replacement for the tablet driver. Leave the official driver installed; Alula only remaps those two mouse buttons, and only while Krita is focused by default.

## Gestures

Each 4th/5th-click button can enable any mix of:

- single click
- double click
- click and hold
- double-click and hold

Disabled gestures are skipped, so Alula only inserts a wait when two **enabled** gestures would otherwise look the same. Example: with hold on and single click off, zoom starts immediately. With undo (click) and sample (hold) both on, it waits `HoldMs` to tell them apart.

The first tap of a double-click-hold may flash the single-hold action for a moment if that hold starts immediately.

## Why 4th and 5th click

Those buttons are unused in Krita’s canvas, and AutoHotkey can see them reliably. Right click and middle click are already used for painting and panning, so stealing them would fight the app.
