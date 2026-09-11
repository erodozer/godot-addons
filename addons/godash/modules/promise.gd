## Utility functions for common Asynchronous operations
extends Object

## Short-hand function to allow for playing and awaiting completion of an Animation with a single call
static func play_animation(a: AnimationPlayer, n: StringName, reverse = false):
	if reverse:
		a.play_backwards(n)
	else:
		a.play(n)
	await a.animation_finished

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
