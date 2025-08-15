@tool
extends ItemList

signal content_selected(resource_type: ContentResource)

func _ready() -> void:
	_load_content_types()
	
func _load_content_types():
	clear()
	
	for meta_instance in ContentManager._types:
		add_item(meta_instance.category().capitalize())
		set_item_metadata(%TypeMenu.item_count - 1, meta_instance)
		
	if item_count > 0:
		select(0)
		item_selected.emit(0)

func _on_item_selected(index: int) -> void:
	var resource_type = get_item_metadata(index)
	content_selected.emit(resource_type)
	
func _on_add_button_pressed() -> void:
	EditorInterface.get_script_editor().open_script_create_dialog(
		"ContentResource",
		"res://content/_types/"
	)
	
