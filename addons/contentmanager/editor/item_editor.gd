@tool
extends Control

var backup: ContentResource
var record: ContentResource :
	set(resource):
		for i in get_children():
			remove_child(i)
			i.queue_free()
		
		if resource == null:
			backup = null
			record = null
		
			return
		
		backup = resource.get_script().new()
		backup.copy_from_resource(resource)
		record = resource
		
		var type_editor: Control = resource.editor()
		
		type_editor.name = "EditorView"
		var editor = type_editor
		editor.edit(record)
		editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(editor)

signal record_updated

func _on_save_pressed() -> void:
	var err = ResourceSaver.save(record)
	if err == OK:
		print("[ContentManager] saved")
		backup.copy_from_resource(record)
		EditorInterface.get_resource_filesystem().scan()
		record_updated.emit()
	else:
		push_error("[ContentManager] unable to save content changes")
		
func _on_delete_pressed() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(record.resource_path))
	record = null
	EditorInterface.get_resource_filesystem().scan()
	record_updated.emit()
	
func _on_revert_pressed() -> void:
	record.copy_from_resource(backup)

func _on_clean_pressed() -> void:
	var clean = Resource.new()
	clean.set_script(record.get_script())
	record.copy_from_resource(clean)
	
