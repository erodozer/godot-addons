@tool
extends Control

var _backup: ContentResource
var record: ContentResource :
	set(r):
		_backup = r
		if r:
			record = r.duplicate()
		if _editor:
			_editor.edit(record)
		
var _editor

signal record_updated

func revert():
	record = _backup

func save_changes():
	var path = _backup.resource_path
	var is_new = path.is_empty()
	path = "res://content/%s/%s.tres" % [_backup.category(), record.resource_name]
	var renamed = _backup.resource_name != record.resource_name
	if renamed and FileAccess.file_exists(path):
		push_error("[ContentManager] resource already exists with name ", record.resource_name)
		return false
	print("[ContentManager] saving changes to ", path)
	
	var err = ResourceSaver.save(
		_editor.get_edited_object(),
		path,
		ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
	)
	if err == OK:
		print("[ContentManager] saved")
		if renamed and not is_new:
			DirAccess.remove_absolute(_backup.resource_path)
			_backup.free()
		_backup = record
		record.set_path_cache(path)
		record_updated.emit()
		return true
	else:
		push_error("[ContentManager] unable to save content changes")
		return false

func _on_content_selected(resource_type) -> void:
	for i in $EditorView.get_children():
		i.queue_free()
		
	var type_editor: Control = resource_type.editor()
		
	type_editor.name = "EditorView"
	_editor = type_editor
	_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$EditorView.replace_by(_editor)

func _on_record_selected(resource) -> void:
	record = resource

func _on_delete_pressed() -> void:
	if _backup != null:
		DirAccess.remove_absolute(_backup.resource_path)
		record = null
		_backup = null
		record_updated.emit()
	
