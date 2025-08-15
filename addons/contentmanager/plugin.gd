@tool
extends EditorPlugin

const EditorPanel = preload("./editor/editor_panel.tscn")

var _instance

func _enter_tree():
	add_autoload_singleton("ContentManager", "res://addons/contentmanager/content_manager.gd")
	_instance = EditorPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(_instance)
	_make_visible(false)

func _exit_tree():
	if _instance:
		_instance.queue_free()
		remove_autoload_singleton("ContentManager")

func _has_main_screen():
	return true

func _make_visible(visible):
	if _instance:
		_instance.visible = visible

func _get_plugin_name():
	return "Content Manager"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
