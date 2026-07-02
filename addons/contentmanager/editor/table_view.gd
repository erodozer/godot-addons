@tool
extends ScrollContainer

var content: ContentResource
var columns: Array
var records = []
	
func _on_content_selected(resource_type: ContentResource) -> void:
	content = resource_type
	if is_visible_in_tree():
		_reload()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			_reload()

func clear():
	for i in %ItemList.get_children():
		i.queue_free()
	records = []

func commit():
	for r in records:
		var path = "res://content/%s/%s.tres" % [r.category(), r._id]
		r.take_over_path(path)
		ResourceSaver.save(r, path)
				
func _add_row(rs: ContentResource = content.get_script().new()) -> void:
	var del = Button.new()
	del.custom_minimum_size = Vector2(32, 0)
	del.text = "-"
	del.toggle_mode = true
	del.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	%ItemList.add_child(del)
	
	var editor = EditorInspector.new()
	editor.edit(rs)
	var fields = []
	for i in columns:
		var f = editor.instantiate_property_editor(rs, i.type, i.name, i.hint, i.hint_string, i.usage, false)
		f.custom_minimum_size = Vector2(150, 0)
		f.draw_label = false
		f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		f.set_object_and_property(rs, i.name)
		f.update_property()
		f.deselect()
		%ItemList.add_child(f)
		fields.append(f)
	fields.append(del)
	
	del.pressed.connect(
		func ():
			var is_new = rs.resource_path.is_empty()
			if not is_new:
				return
			for f in fields:
				f.queue_free()
				records.erase(rs)
	)
	
	records.append(rs)
			
func _reload():
	if content == null:
		return
	
	for i in %ItemList.get_children():
		i.queue_free()
		
	await get_tree().process_frame
	
	print("[Content Manager] reloading table")
	
	# make the header row
	columns = []
	var space = Control.new()
	space.custom_minimum_size = Vector2(32, 0)
	%ItemList.add_child(space)
	for i in content.get_property_list():
		if i.usage & PROPERTY_USAGE_EDITOR == 0:
			continue
		if i.usage & PROPERTY_USAGE_INTERNAL:
			continue
			
		var label = Label.new()
		label.text = i.name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		%ItemList.add_child(label)
		columns.append(i)
	%ItemList.columns = len(columns) + 1
	
	var path = "res://content/%s" % content.category()
	for r in ResourceLoader.list_directory(path):
		# only load resource files
		if not r.ends_with(".tres"):
			continue
		var fp = path.path_join(r)
		var rs = ResourceLoader.load(fp, "", ResourceLoader.CACHE_MODE_REPLACE)
		assert(rs != null, "resource is unexpectedly null")
		
		_add_row(rs)
	
