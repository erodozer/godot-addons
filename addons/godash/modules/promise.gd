## Utility functions for common Asynchronous operations
extends Object

## Short-hand function to allow for playing and awaiting completion of an Animation with a single call
static func play_animation(a: AnimationPlayer, n: StringName, reverse = false):
	if reverse:
		a.play_backwards(n)
	else:
		a.play(n)
	await a.animation_finished

## Performs a callable action within a task on the [WorkerThreadPool] and returns its result.[br]
## Yields control back to the main loop by only checking thread status once per frame when awaited.
static func async_task(callable: Callable) -> Variant:
	# wrapper callable to handle data transfer out of the thread
	var thread_return: Callable = func (holder):
		var out = callable.call()
		holder["return"] = out

	# Local variables are pass by value with Godot's callables, so we can not mutate anything
	# in the immediate parent scope of a lambda function.  To work around this, we can use
	# a data container that is passed by reference to the callable through a parameter.
	var result: Dictionary[String, Variant] = { "return": null }
	var task_id: int = WorkerThreadPool.add_task(thread_return.bind(result))

	# when a main loop is able to signal for yielding, avoid long duration blocking by using
	# minimal status checks only once per cycle
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		while not WorkerThreadPool.is_task_completed(task_id):
			await main_loop.process_frame

	# Cleanup internal resources.  When the main loop supports yielding, this will not
	# cause any significant pause as the task will already be completed by this point.
	# Otherwise, this will block the process.
	WorkerThreadPool.wait_for_task_completion(task_id)
	return result.get("return")

## Mutex-like helper for coroutines
## Async callables are handled in a FIFO thanks to Godot's IO-loop
class PromiseQueue:
	var guard = false
	
	signal open
	
	func queue(fn: Callable):
		while guard:
			await open
		guard = true
		await fn.call()
		guard = false
		open.emit()
	
## Mutex-like helper for coroutines
## Handles async callables in a FILO, which is unnatural to IO-loops
class PromiseStack:
	var guard = false
	var stack = []
	signal open
	
	func push(fn: Callable):
		stack.append(fn)
		while guard:
			await open
			if stack[-1] == fn:
				break
		guard = true
		await fn.call()
		stack.pop_back()
		guard = false
		open.emit()
