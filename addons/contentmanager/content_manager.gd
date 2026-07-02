@tool
extends Node
	
const DB_PATH = preload("./plugin.gd").DB_PATH
	
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
	_db = JSON.parse_string(
		FileAccess.get_file_as_string("res://content/cmdb.json")
	)

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
	return _db[content_type.category()] as Array[String]

func load_list(content_type: ContentResource) -> Array[ContentResource]:
	return list_content(content_type).map(
		func (v):
			var res = load(v) as ContentResource
			assert(res != null, "unable to load resource: %s" % v)
			return res,
	)
