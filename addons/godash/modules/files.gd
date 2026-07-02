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
