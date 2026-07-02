@tool
extends Control

var filepath: String
var content: ContentResource
var backup: ContentResource
var record: ContentResource
		
var editor
@onready var view = %EditorView

signal record_updated

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree() and filepath != null:
		var r = load(filepath)
		assert(r != null, "unable to load visible resource")
		_on_content_selected(r)
		_on_record_selected(r)
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		for i in view.get_children():
			i.queue_free()
		
		record = null
		backup = null
		content = null
			
func revert():
	record.copy_from_resource(backup)

func save_changes():
	var is_new = filepath.is_empty()
	var path = "res://content/%s/%s.tres" % [record.category(), record._id]
	var renamed = backup._id != record._id
	if renamed and FileAccess.file_exists(path):
		push_error("[ContentManager] resource already exists with name ", record._id)
		return false
	print("[ContentManager] saving changes to ", path)
	
	# make sure the path exists
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path).get_base_dir())
	
	var err = ResourceSaver.save(
		editor.get_edited_object(),
		path,
		ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
	)
	if err == OK:
		print("[ContentManager] saved")
		if renamed and not is_new:
			DirAccess.remove_absolute(backup.resource_path)
		backup = record
		record.take_over_path(path)
		EditorInterface.get_resource_filesystem().scan()
		record_updated.emit()
		return true
	else:
		push_error("[ContentManager] unable to save content changes")
		return false

func _on_content_selected(resource_type: ContentResource) -> void:
	for i in view.get_children():
		i.queue_free()
		
	var type_editor: Control = resource_type.editor()
		
	type_editor.name = "EditorView"
	editor = type_editor
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.add_child(editor)
	
	content = resource_type

func _on_record_selected(resource: ContentResource) -> void:
	filepath = resource.resource_path
	backup = content.get_script().new()
	backup.copy_from_resource(resource)
	record = resource
	if editor:
		editor.edit(record)
		
func _on_delete_pressed() -> void:
	if backup != null:
		DirAccess.remove_absolute(backup.resource_path)
		record = null
		backup = null
		EditorInterface.get_resource_filesystem().scan()
		record_updated.emit()
	
