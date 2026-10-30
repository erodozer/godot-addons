@tool
extends EditorPlugin

const CustomInspector = preload("./multimesh_baker.gd")

var _inspector: EditorInspectorPlugin

func _enter_tree() -> void:
	_inspector = CustomInspector.new()
	add_inspector_plugin(_inspector)
	
func _exit_tree() -> void:
	remove_inspector_plugin(_inspector)
	_inspector = null
