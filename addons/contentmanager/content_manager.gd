## ContentManager
## [br]
##
## Centralized Resource data storage system, enforcing opinionated storage patterns.
@tool
extends Node

const CONTENT_PATH = "res://content"
const DB_PATH = "res://content/cm.db"

## Scans through the project and writes a file index to disk representing
## a database of all available content resources.  This file is read at
## project runtime to overcome res:// traversal in exported projects.
func _write_db_to_disk():
	assert(Engine.is_editor_hint(), "writing should only occur in Editor")
	
	var file = FileAccess.open(DB_PATH, FileAccess.WRITE)
	
	# build header
	var types = enumerate_types()
	var type_count = len(types)
	# reserve header
	for i in range(type_count):
		file.store_32(0)
	
	# byte position
	var cursor = 4 * type_count # end of header
	for i in range(type_count):
		# write start position for the type back into the header
		file.seek(4 * i)
		file.store_32(cursor)
		file.seek(cursor)
		
		var c = types[i]
		var content_dir = CONTENT_PATH.path_join(c.category)
		for filepath in DirAccess.get_files_at(content_dir):
			if not filepath.ends_with(".tres"):
				continue
			# only encode name of the file, as extension and full path are deterministic
			var name = filepath.get_file().get_basename()
			var buffer = name.to_utf8_buffer()
			file.store_8(buffer.size()) # string length
			file.store_buffer(buffer) # file name
			cursor += buffer.size() + 1 # adjust cursor to end of entry
	
	file.close()

# type caching
var _types: Dictionary[StringName, Dictionary] = {}
var _types_enum: Array[Dictionary] = []

## Discover all available ContentResource types in a project
func enumerate_types() -> Array[Dictionary]:
	if not Engine.is_editor_hint():
		# prefer using cached index at runtime
		if not _types.is_empty():
			return _types_enum
		
	var types = ProjectSettings.get_global_class_list().filter(
		func (d):
			return d.base == "ContentResource"
	)
	_types_enum.resize(len(types))
	for idx in range(len(types)):
		var c = types[idx]
		var meta_instance: ContentResource = load(c.path).new()
		meta_instance.set_meta("class_name", c.class)
		meta_instance.set_meta("class_id", idx)
		var clz = StringName(c.class)
		var type = {
			"class_name": clz,
			"class_id": idx,
			"category": meta_instance.category(),
			"meta_instance": meta_instance,
		}
		_types[clz] = type
		_types_enum[idx] = type
	
	return _types_enum

## Get list of Resource paths associated with a ContentType with the matching classname
func list_content(content_type: StringName) -> Array[String]:
	enumerate_types()
	var type = _types.get(content_type)
	var db = FileAccess.open(DB_PATH, FileAccess.READ)
	
	# read header
	db.seek(type.class_id * 4)
	var start: int = db.get_32()
	var end: int = db.get_length()
	if type.class_id + 1 < len(_types):
		end = db.get_32()
	
	# list files
	db.seek(start)
	var acc: Array[String] = []
	while db.get_position() < end:
		var length = db.get_8()
		var filename = db.get_buffer(length).get_string_from_utf8()
		acc.append(
			CONTENT_PATH.path_join(type.category).path_join(
				"%s.tres" % filename
			)
		)
	db.close()
	return acc

## Loads all resources associated with a Content type.[br]Typically used for interfaces
## where you may need to enumerate all available options, such as NPC Shops.[br]
## Only use this when you know it's safe to load all resources in a directory into memory.
func load_list(content_type: StringName) -> Array[ContentResource]:
	return list_content(content_type).map(
		func (v):
			var res = load(v) as ContentResource
			assert(res != null, "unable to load resource: %s" % v)
			return res,
	)
