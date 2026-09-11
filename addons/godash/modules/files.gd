extends Object

## Fetch a list of files in a directory that match the extension.
## Note: directories within the [pre]res://[/pre] filesystem can not be traversed in exported projects
static func enumerate_dir(dir: String, extension: Array = [""], recurse: bool = true) -> Array:
	var files: Array[String] = []
	for f in DirAccess.get_files_at(dir):
		for e in extension:
			if e.is_empty() or f.ends_with(e):
				files.append(dir.path_join(f))
		
	if recurse:
		for d in DirAccess.get_directories_at(dir):
			files.append_array(enumerate_dir(dir.path_join(d), extension, recurse))
	
	return files

## Load all resource assets from a directory.
## [br]
## This uses blocking io and is not suitable for large directories with lots of big files
static func load_dir(resource_dir, ext = ['.tres'], recurse = false) -> Dictionary:
	var files = enumerate_dir(resource_dir, ext, recurse)
	return files.reduce(
		func (d, f):
			d[f] = load(f)
			return d,
		{}
	)

## Coroutine wrapping a Threaded load request
static func load_async(path):
	await Engine.get_main_loop().process_frame
	var loader = ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await Engine.get_main_loop().process_frame
	
	return ResourceLoader.load_threaded_get(path)

## Recursively walks a Directory tree for files ending with the provided extension
static func walk_files(dir: String, extension: String = [], recursive = true) -> Array[String]:
	var files: Array[String] = []
	for f in DirAccess.get_files_at(dir):
		var matches = extension.is_empty()
		for e in extension:
			if f.ends_with(extension):
				matches = true
				break
		if matches:
			files.append(dir.path_join(f))

	if recursive:		
		for d in DirAccess.get_directories_at(dir):
			files.append_array(walk_files(dir.path_join(d), extension))
	
	return files

## safely parses JSON data from a file
static func read_json(filepath: String) -> Dictionary:
	var file = FileAccess.get_file_as_string(filepath)
	var data = JSON.parse_string(file)
	if data == null:
		push_error("Unable to parse JSON from file: ", filepath)
		return {}
	return data

## persists data into a readable JSON file
static func write_json(filepath: String, data: Dictionary, indent: int = 2) -> Error:
	var f = FileAccess.open(filepath, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	
	var out = JSON.stringify(data, " ".repeat(indent))
	var success = f.store_string(out)
	f.close()
	
	return OK if success else ERR_CANT_CREATE
