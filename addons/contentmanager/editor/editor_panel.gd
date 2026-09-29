@tool
extends Control

var records = {}

func _notification(what: int) -> void:
	# when running in the editor, build up a JSON file that indexes
	# all the resource files.  This JSON needs to be included on export and read
	# since iterating over the Res dir is not supported in exported projects.
	if is_node_ready():
		# rebuild the index in case files were added directly through the file system
		# while the editor was out of focus
		if what == NOTIFICATION_VISIBILITY_CHANGED:
			%ItemEditor.record = null
			_build_index()
	elif what == NOTIFICATION_READY:
		_build_index()
	
func _build_index():
	var db = {}
	var category_count = 0
	var resource_count = 0
	%Records.clear()
	%TypeSelector.clear()
	
	var tree = {}
	var root: TreeItem = %Records.create_item()
	for content_type in ContentManager.enumerate_types():
		var section = root
		var path: String = content_type.category
		var idx = 0
		var slice = path
		var section_name = ""
		while idx > -1:
			idx = path.find("/", idx + 1)
			slice = path.substr(0, idx)
			
			if slice in tree:
				section = tree[slice]
				continue

			var leaf: TreeItem = %Records.create_item(section)
			section_name = slice.substr(slice.rfind("/") + 1).capitalize()
			leaf.set_text(0, section_name)
			if slice == path:
				leaf.set_icon(0, content_type.meta_instance.editor_icon())
				leaf.set_selectable(0, true)
				leaf.set_metadata(0, content_type)
			else:
				leaf.set_selectable(0, false)
				
			section = leaf
			tree[slice] = leaf
		
		%TypeSelector.add_item(section_name)
		%TypeSelector.set_item_metadata(%TypeSelector.item_count - 1, content_type)
		
		category_count += 1
		var resources = []
		var content_dir = ContentManager.CONTENT_PATH.path_join(content_type.category)
		for filepath in DirAccess.get_files_at(content_dir):
			if not filepath.ends_with(".tres"):
				continue
			var record = load(content_dir.path_join(filepath))
			var item: TreeItem = %Records.create_item(section)
			item.set_text(0, record._id)
			item.set_selectable(0, true)
			item.set_metadata(0, record)
			records[record] = item
			resources.append(record.resource_path)
			resource_count += 1
		db[content_type.category] = resources
	
	# make sure the db is up to date every time the index is built
	# this helps make sure the export includes references to all
	# available files
	ContentManager._write_db_to_disk()
	
	%Stats.text = "Types: {0} | Resources: {1}".format(
		[category_count, resource_count]
	)

func _on_record_search_text_changed(new_text: String) -> void:
	for record in records:
		records[record].visible = new_text.is_empty() or new_text in record._id
	
func _on_new_content_type_pressed() -> void:
	EditorInterface.get_script_editor().open_script_create_dialog(
		"ContentResource",
		"res://content/_types/"
	)

func _on_new_document_pressed() -> void:
	
	%NewDocumentPopup.popup_centered()

func _on_new_document_popup_confirmed() -> void:
	var content_type: ContentResource = %TypeSelector.get_selected_metadata()
	var resource_id = %DocumentName.text
	var new_resource = Resource.new()
	new_resource.set_script(content_type.get_script())
	new_resource.resource_path = ContentManager.DB_PATH.get_base_dir().path_join(content_type.category()).path_join(resource_id + ".tres")
	
	var abs_path = ProjectSettings.globalize_path(new_resource.resource_path)
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	
	ResourceSaver.save(new_resource)
	_build_index()
	for r in records:
		if r.resource_path == new_resource.resource_path:
			%Records.set_selected(records[r], 0)

func _on_records_item_activated() -> void:
	var selected = %Records.get_selected()
	var record = selected.get_metadata(0)
	if record:
		if "meta_instance" in record:
			var script = record.meta_instance.get_script()
			EditorInterface.edit_script(script)
			EditorInterface.set_main_screen_editor("Script")
		else:
			%ItemEditor.record = record as ContentResource
			%DocumentControls.show()
	else:
		%DocumentControls.hide()
