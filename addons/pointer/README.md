# Pointer

On-screen cursor for directing user's attention.

Useful in menu heavy games, or low resolution games where additional indication is helpful to highlight interactive elements.  Works as a substitute for a mouse, or 

## Settings

### Mouse Mode

The pointer will follow the position of the mouse when the mouse is within the bounds of the viewport.

Not as efficient as Godot's built-in OS Cursor skinning, but provides use as a shared component that can be used with mouse, keyboard, and gamepad control.

### Focus Mode

The pointer can be set to reposition itself globally to attach to whatever element within its viewport has focus.

#### Customizing Anchoring

Within elements that can receive focus, you can embed a Node2D named `PointerAnchor`.  This is used by Pointer to know a specific offset to be positioned by when highlighting the element.

#### Smoothing

When the pointer moves to a new position, whether programmatically or by focus, it will tween to its new position.  Toggle this off if you would prefer it move immediately, or if calling the function directly pass the extra flag to control smoothing. 

#### Wiggle

When the pointer moves to a new position, whether programmatically or by focus, it has a visual effect that simulates physical drag and bounce.  This effect can be toggled if it does not fit the aesthetic of your UI.

Wiggle only plays when Smoothing is enabled.

## Assets

Pointer graphic by @erodozer is included for use under CC-0

