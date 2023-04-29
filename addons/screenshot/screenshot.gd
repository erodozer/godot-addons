"""
Screenshot.gd
@author Nicholas Hydock <nhydock@gmail.com>
@description |>
	Simple global tool for capturing crisp screenshots with a hotkey
"""

extends Node

const interval = 1.0/30.0
const record_wait = 2.0
var record = false
var holding = false
var held = 0

func snap():
	var dir = Directory.new()
	if not dir.dir_exists("user://screenshots"):
		dir.make_dir_recursive("user://screenshots")
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png("user://screenshots/%d.png" % OS.get_system_time_msecs())
		
func _input(event):
	if event.is_action_pressed("ui_screenshot"):
		snap()
		holding = true
		record = false
		held = 0
	if event.is_action_released("ui_screenshot"):
		holding = false
		record = false

func _process(delta):
	if record:
		held += delta
		if held > interval:
			held = fmod(held, interval)
			snap()
	elif holding:
		held += delta
		if held > record_wait:
			record = true
			snap()
			held = 0
