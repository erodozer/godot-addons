# godot-pause-stack

For games that have multiple layers of state control and tons of conditions around what to do when paused, Godot's built-in scene tree pausing capabilities might not be enough.

Pause Stack was written for A:\dventure which is a menu heavy game with lots of different contexts.  Coroutines worked fine for awhile, but the complexity grew to a point where all the signals and async led to spaghetti in many places.  This addon is designed to help centralize and simplify what it means to be "paused" and understanding what menus are open in what order based on the stack.

## Usage

Simply add the Pause.gd script as a singleton node to your project.

The Pause Stack may be manipulated and watched using the `pause()` and `resume()` methods on the Node.

As it is a stack, when resuming you must resume in the reverse order that you paused.  Reasons are provided to the method calls to establish the association.  You can not append the same reason multiple times to the stack.

## Signals

### paused(reason)
Emitted each time the stack is appended

### resumed
Emitted once the pause stack is empty

## Example

```gdscript
# Inventory.gd

func open():
  PauseStack.pause('menu.inventory')
  
  set_process_input(true)
  yeild(self, "close")
  set_process_input(false)

  PauseStack.resume('menu.inventory')
```
```
# Player.gd
func _enter_tree():
  PauseStack.connect('paused', self, 'on_paused')
  PauseStack.connect('resumed', self, 'on_resume')

func on_paused(reason):
  set_process(false)

func on_resume():
  set_process(true)
```