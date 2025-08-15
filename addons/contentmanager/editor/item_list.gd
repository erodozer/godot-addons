@tool
extends Control

signal record_selected(resource: ContentResource)

var active_type: ContentResource

func _on_content_selected(resource_type: ContentResource) -> void:
	%Records.clear()
	for c in ContentManager.list_content(resource_type):
		%Records.add_item(c.get_file().left(-len(".tres")))
		%Records.set_item_metadata(%Records.item_count - 1, c)
	
	if %Records.item_count > 0:
		%Records.select(0)
		await get_tree().process_frame
		%Records.item_selected.emit(0)
		
	active_type = resource_type

func _on_item_selected(index: int) -> void:
	var record = ResourceLoader.load(
		%Records.get_item_metadata(index), "", ResourceLoader.CACHE_MODE_REPLACE
	)
	record_selected.emit(record)

func _on_add_pressed() -> void:
	var record = active_type.duplicate()
	record.resource_name = "new_record"
	%Records.deselect_all()
	record_selected.emit(record)

func _on_item_editor_record_updated() -> void:
	# rebuild the current list to detect updates
	_on_content_selected(active_type)

func _on_edit_schema_pressed() -> void:
	EditorInterface.edit_script(
		active_type.get_script()
	)
	EditorInterface.set_main_screen_editor("Script")
