"""
PauseStack.gd
@author Erodozer <ero@erodozer.moe>
@description |>
	Pause stack is a simple state manager for complex pause state in a game.
	Use this as a replacement for toggling get_tree().pause.  This gives finer
	grained control by allowing you to explicitly manage processing on Nodes
	under certain pause conditions instead of requiring it be tied to the global
	pause state that Godot offers.  That way get_tree().pause can be utilized
	for more general mass pausing that matters, such as preventing continuous
	processing when transitioning scenes.
	
	Register this as a singleton in your project.
"""
extends Node

var registry = []

## signal emitted whenever a new pause state is added to the stack
signal paused(reason)

## signal emitted when the stack is completely clear
signal resumed

func is_paused(reason = "") -> bool:
	if reason.is_empty():
		return not registry.is_empty()
	return reason in registry

func pause(reason: String = 'game.paused'):
	var is_paused = self.is_paused
	assert(reason not in registry, "incorrect state in pause stack, reason can not be present in the stack multiple times.  Duplicate: %s" % reason)
	registry.append(reason)
	paused.emit(reason)
	
func resume(reason: String):
	assert(reason in registry, "incorrect state from pause stack, reason is missing.  Reason %s" % reason)
	
	registry.erase(reason)
	
	if not is_paused():
		resumed.emit()
