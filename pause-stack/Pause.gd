"""
PauseStack.gd
@author Nicholas Hydock <nhydock@gmail.com>
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

var pause_stack = []

signal paused(reason)
signal resumed()

var is_paused setget ,get_paused

func get_paused():
	return len(pause_stack) > 0

func pause(reason = 'game.paused'):
	var is_paused = self.is_paused
	assert(not(reason in pause_stack), "incorrect state in pause stack, reason can not be present in the stack multiple times.  Duplicate: %s" % reason)
	pause_stack.append(reason)
	if not is_paused:
		emit_signal("paused", reason)
	
func resume(reason):
	var source = pause_stack.pop_back()
	assert(source == reason, "incorrect state from pause stack, fix your cleanup. Expected %s, Found %s" % [reason, source])
	if !get_paused():
		emit_signal("resumed")
