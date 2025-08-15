@tool
extends Node
	
var _types = []
var _categories = {}
	
func _ready() -> void:
	# enumerate available content types
	_enumerate_types()
	
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
	var records: Array[String] = []
	var path = "res://content/%s" % content_type.category()
	for r in ResourceLoader.list_directory(path):
		# only load resource files
		if not r.ends_with(".tres"):
			continue
		var fp = path.path_join(r)
		records.append(fp)
	return records
	
