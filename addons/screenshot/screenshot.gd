"""
Screenshot.gd
@author Erodozer <ero@erodozer.moe>
@description |>
	Simple global tool for capturing crisp screenshots with a hotkey
"""

extends Node

@onready var screenshot_path = ProjectSettings.globalize_path("user://screenshots")

@export var interval = 1.0
var timer: Timer

func _ready() -> void:
	var timer = Timer.new()
	timer.timeout.connect(snap)
	add_child(timer)

func snap():
	if not DirAccess.dir_exists_absolute(screenshot_path):
		DirAccess.make_dir_recursive_absolute(screenshot_path)
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png("user://screenshots/%d.png" % Time.get_unix_time_from_system())
		
func _input(event):
	if event.is_action_pressed("ui_screenshot"):
		snap()
		timer.start(interval)
	if event.is_action_released("ui_screenshot"):
		timer.stop()
