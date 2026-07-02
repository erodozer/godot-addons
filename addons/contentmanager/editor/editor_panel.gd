@tool
extends Control

const DB_PATH = preload("../plugin.gd").DB_PATH

func _notification(what: int) -> void:
	# when running in the editor, build up a JSON file that indexes
	# all the resource files.  This JSON needs to be included on export and read
	# since iterating over the Res dir is not supported in exported projects.
	if is_node_ready():
		if what == NOTIFICATION_VISIBILITY_CHANGED:
			_build_index()
	elif what == NOTIFICATION_READY:
		_build_index()
	
func _build_index():
	var db = {}
	for i in range(%TypeMenu.items.item_count):
		var type = %TypeMenu.items.get_item_metadata(i) as ContentResource
		assert(type != null, "invalid content resource type %s" % type)
		db[type.category()] = %ItemList.list_content(type)
		
	var f = FileAccess.open(DB_PATH, FileAccess.WRITE_READ)
	f.store_string(JSON.stringify(db, "  "))
	f.close()
	print("[ContentManager] updated %s" % DB_PATH)
	
