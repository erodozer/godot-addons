@tool
extends Control

signal content_selected(resource_type: ContentResource)

@onready var items: ItemList = %Items
var active: ContentResource

func _ready() -> void:
	visibility_changed.connect(_load_content_types)
	
func _load_content_types():
	if not is_visible_in_tree():
		return
	items.clear()

	for c in ProjectSettings.get_global_class_list().filter(
		func (d):
			return d.base == "ContentResource"
	):
		var meta_instance: ContentResource = load(c.path).new()
		
		items.add_item(meta_instance.category().replace("/", " ").capitalize())
		items.set_item_metadata(items.item_count - 1, meta_instance)
		
	if items.item_count > 0:
		items.select(0)
		items.item_selected.emit(0)

func _on_item_selected(index: int) -> void:
	var resource_type = items.get_item_metadata(index)
	active = resource_type
	content_selected.emit(resource_type)
	
func _on_add_button_pressed() -> void:
	EditorInterface.get_script_editor().open_script_create_dialog(
		"ContentResource",
		"res://content/_types/"
	)
	
func _on_edit_schema_pressed() -> void:
	EditorInterface.edit_script(
		active.get_script()
	)
	EditorInterface.set_main_screen_editor("Script")
