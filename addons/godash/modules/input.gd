extends RefCounted

## Tests a list of buttons to make sure they have all been pressed
static func combined(actions: Array[StringName]) -> bool:
	var pressed = true
	for i in actions:
		pressed = pressed and Input.is_action_pressed(i)
	return pressed
	
## Tests a list of buttons to make sure all are pressed, capturing the moment when the last button in the combination is pressed
static func just_combined(actions: Array[StringName]) -> bool:
	var is_combined = combined(actions)
	if is_combined:
		for i in actions:
			if Input.is_action_just_pressed(i):
				return true
	return false

## Look for a given sequence of inputs
class InputSequence:
	var _mask: Array[StringName]
	var _buffer: Array[StringName]
	var _timings: Array[float]
	
	func _init(input_mask: Array[StringName]) -> void:
		_mask = input_mask
	
	func record():
		var now = Time.get_unix_time_from_system()
		for i in _mask:
			if Input.is_action_just_pressed(i):
				_buffer.append(i)
				_timings.append(now)
		# trim timings
		var trim = 0
		for i in _timings:
			if i < now - 1.0:
				trim += 1
		_timings = _timings.slice(trim)
		_buffer = _buffer.slice(trim)
	
