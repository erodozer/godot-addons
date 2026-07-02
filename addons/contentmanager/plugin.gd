@tool
extends EditorPlugin

const EditorPanel = preload("./editor/editor_panel.tscn")

const AUTOLOAD_NAME = "ContentManager"
const DB_PATH = "res://content/cmdb.json"

var _instance

func _enable_plugin():
	# The autoload can be a scene or script file.
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/contentmanager/content_manager.gd")

func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_NAME)

func _enter_tree():
	_instance = EditorPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(_instance)
	_make_visible(false)

func _exit_tree():
	if _instance:
		_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if _instance:
		_instance.visible = visible

func _get_plugin_name():
	return "Content Manager"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("ResourcePreloader", "EditorIcons")
