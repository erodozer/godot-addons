## Screenshot
## 
## @author Erodozer <ero@erodozer.moe>
## [br]
## Tool for capturing crisp screenshots of any viewport at internal resolutions with a hotkey.
## Files are saved to the user's Pictures directory in PNG quality.
## Add as a singleton for enabling the functionality for the entire application lifecycle.
extends Node

signal screenshot_saved(filename: String)

func snap(viewport = get_viewport(), idx = Time.get_unix_time_from_system()) -> String:
	var hide_state = {}
	for i in get_tree().get_nodes_in_group("hide_screenshot"):
		if "visible" in i:
			hide_state[i] = i.visible
			i.visible = false
	
	await RenderingServer.frame_post_draw
	
	var pictures = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	var appname = ProjectSettings.get_setting("application/config/name")
	var image = viewport.get_texture().get_image()
	var filename = pictures.path_join("%s_%d.png" % [appname, idx])
	image.save_png(filename)
	
	for i in hide_state.keys():
		i.visible = hide_state[i]
		
	screenshot_saved.emit(filename)
	return filename

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_screenshot"):
		snap()
		get_tree().set_input_as_handled()
