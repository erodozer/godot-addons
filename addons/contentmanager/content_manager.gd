@tool
extends Node
	
const DB_PATH = "res://content/cmdb.json"
	
var _types = []
var _categories = {}

# preindexed list of content
var _db = {}
	
func _ready() -> void:
	# enumerate available content types
	_enumerate_types()
	
	# when running in the editor, build up a JSON file that indexes
	# all the resource files.  This JSON needs to be included on export and read
	# since iterating over the Res dir is not supported in exported projects.
	if Engine.is_editor_hint():
		_build_index()
	else:
		_db = JSON.parse_string(
			FileAccess.get_file_as_string("res://content/cmdb.json")
		)
	
func _build_index():
	var db = {}
	for type in _types:
		db[type.category()] = list_content(type)
	var f = FileAccess.open(DB_PATH, FileAccess.WRITE_READ)
	f.store_string(JSON.stringify(db, "  "))
	f.close()
	_db = db
	print("[ContentManager] updated %s" % DB_PATH)
	
func _enumerate_types():
	var types = []
	var categories = {}
	for c in ProjectSettings.get_global_class_list().filter(
		func (d):
			return d.base == "ContentResource"
	):
		var meta_instance: ContentResource = load(c.path).new()
		types.append(meta_instance)
		categories[c.class] = meta_instance.category()
	
	print("[ContentManager] discovered resource types: ", categories.keys())
	
	_types = types
	_categories = categories
	
func list_content(content_type: ContentResource) -> Array[String]:
	if Engine.is_editor_hint():
		var records: Array[String] = []
		var path = "res://content/%s" % content_type.category()
		for r in ResourceLoader.list_directory(path):
			# only load resource files
			if not r.ends_with(".tres"):
				continue
			var fp = path.path_join(r)
			records.append(fp)
		return records
	else:
		return _db[content_type.category()] as Array[String]
	
