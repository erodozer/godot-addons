@tool
extends Control

signal record_selected(resource: ContentResource)

var active_type: ContentResource
var open_record: ContentResource

@onready var item_list = %Records

func list_content(resource_type: ContentResource) -> Array[String]:
	var records: Array[String] = []
	var path = "res://content/%s" % resource_type.category()
	for r in ResourceLoader.list_directory(path):
		# only load resource files
		if not r.ends_with(".tres"):
			continue
		var fp = path.path_join(r)
		records.append(fp)
	return records

func _on_content_selected(resource_type: ContentResource) -> void:
	item_list.clear()

	for c in list_content(resource_type):
		item_list.add_item(c.get_file().left(-len(".tres")))
		item_list.set_item_metadata(item_list.item_count - 1, c)
	
	if is_visible_in_tree():
		if item_list.item_count > 0:
			item_list.select(0)
			await get_tree().process_frame
			item_list.item_selected.emit(0)
		
	active_type = resource_type

func _on_item_selected(index: int) -> void:
	var path = item_list.get_item_metadata(index)
	assert(path != null, "invalid item path")
	var record = ResourceLoader.load(
		path, "", ResourceLoader.CACHE_MODE_REPLACE
	)
	open_record = record
	record_selected.emit(record)

func _on_add_pressed() -> void:
	var record = active_type.duplicate()
	record.resource_name = "new_record"
	item_list.deselect_all()
	record_selected.emit(record)

func _on_item_editor_record_updated() -> void:
	var prev_open = open_record._id
	# rebuild the current list to detect updates
	_on_content_selected(active_type)
	
	if prev_open == null:
		return
		
	for i in range(item_list.item_count):
		var path = item_list.get_item_text(i)
		if path == prev_open:
			print("[CM] %s %s" % [path, prev_open])
			item_list.select(i)
			_on_item_selected(i)
			return
