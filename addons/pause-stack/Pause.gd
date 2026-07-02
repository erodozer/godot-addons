## PauseStack
## 
## @author Erodozer <ero@erodozer.moe>
## [br][br]
##	Pause stack is a simple state manager for complex pause state in a game.
##	Use this as a replacement for toggling get_tree().pause.  This gives finer
##	grained control by allowing you to explicitly manage processing on Nodes
##	under certain pause conditions instead of requiring it be tied to the global
##	pause state that Godot offers.  That way get_tree().pause can be utilized
##	for more general mass pausing that matters, such as preventing continuous
##	processing when transitioning scenes.
##  [br]
##	Register this as a singleton in your project.

extends Node

var registry: Array[String] = []

## signal emitted whenever a new pause state is added to the stack
signal paused(reason)
## signal emitted when we resume from a specific pause state
signal unpaused(reason)
## signal emitted when the stack is completely clear
signal resumed

## Check if we are paused.  
func is_paused(reason = "") -> bool:
	if reason.is_empty() or reason == "*":
		return not registry.is_empty()
		
	# simpler than regex path style matching
	# performs begins with check when a wildcard is present
	# wildcards will match everything after they're declared in a string
	var wildcard = reason.rfind("*")
	var exact = reason.left(wildcard)
	for code in registry:
		if wildcard > -1 and code.begins_with(exact):
			return true
		if code == exact:
			return true
	return false

## Pushes a reason for being paused onto the stack.  Values are exact and must not already be present in the stack
func pause(reason: String = 'game.paused'):
	var is_paused = self.is_paused
	assert(reason not in registry, "incorrect state in pause stack, reason can not be present in the stack multiple times.  Duplicate: %s" % reason)
	registry.append(reason)
	paused.emit(reason)
	
## Pops a reason code from the pause stack. Reason must exist in the stack, error will be thrown otherwise
func resume(reason: String):
	assert(reason in registry, "incorrect state from pause stack, reason is missing.  Reason %s" % reason)
	
	registry.erase(reason)
	unpaused.emit(reason)
	
	if not is_paused():
		resumed.emit()
