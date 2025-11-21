# Advanced Global Dispatch System

Having a global event bus is a common pattern with large scale Godot projects.  This implementation expands upon providing just the bare minimum abstract dispatcher by allowing for conditional routing of messages through basic pattern matching.

## How-to Use

To simplify implementation and readibility, pattern matching follows simple Glob-like rules as opposed to complex RegEx support.

Inspiration comes from message queuing systems, particularly RabbitMQ.

As the system is dynamic, it's only possible to register programmatically, unlike traditional signals which are available through the godot editor.

It is important to register the system as a Singleton in your project to use it.
This is necessary both for API accessibility and because per-frame garbage collection is performed to make sure all invalid callable bindings are cleared out over time.

Recommended singleton names would be `Eventbus` or `AGDS`

## Example

```gdscript
func do_stuff(message):
    print("any:", message)

func do_good_stuff(message):
    print("good:", message)

func do_bad_stuff(message):
    print("evil:", message)

func do_whatever_stuff(message):
    print("neutral:", message)

func _ready():
    Eventbus.register(do_stuff) # binds to wildcard by default
	Eventbus.register(do_bad_stuff, "bad.message")
	Eventbus.register(do_good_stuff, "good.*")
	Eventbus.register(do_whatever_stuff, "*.message")
	
	# call any + good + neutral
	Eventbus.dispatch.call_deferred("good.message", "yes")
	# call any + bad + neutral
	Eventbus.dispatch.call_deferred("bad.message", "no")
	# call any + neutral
	Eventbus.dispatch.call_deferred("smelly.message", "yuck")
	# call any
	Eventbus.dispatch.call_deferred("message.foo", "bar")
	# call any + good
	Eventbus.dispatch.call_deferred("good.massage", "mmmff")
```
