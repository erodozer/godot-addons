"""
godash.gd
@author Erodozer <ero@erodozer.moe>
@description |>
	Collection of basic utilities that I find useful for game development
	that overcomes some of the missing features of gdscript
	
	Library and name inspired by lodash for javascript
"""

extends RefCounted

enum SELECT_CHOICE { KEY, VALUE }

static func unique(collection: Array):
	var d = {}
	for i in collection:
		d[i] = true
	return d.keys()

static func rand_choice(collection, select:SELECT_CHOICE = SELECT_CHOICE.VALUE, rand: RandomNumberGenerator = null):
	"""
	Pick randomly out of a collection.

	Has more control than the built-in random function on arrays.
	Uses a supplied RandomNumberGenerator instead of being tied to the global random seed
	"""
	if len(collection) == 0:
		return null
	if rand == null:
		rand = RandomNumberGenerator.new()
		rand.randomize()
	if typeof(collection) == TYPE_DICTIONARY:
		match select:
			SELECT_CHOICE.KEY:
				return collection.keys()[rand.randi() % collection.keys().size()]
			_:
				return collection.values()[rand.randi() % collection.values().size()]
	var idx = rand.randi() % collection.size()
	return collection[idx]

static func rand_chance(collection: Dictionary, rand: RandomNumberGenerator = null):
	"""
	Select a random key from a dictionary based on percentage chances
	defined for each key.
	"""
	
	var keys = []
	var values = []
	
	var total_weight = 0
	for key in collection.keys():
		var weight = collection[key]
		total_weight += weight
		keys.append(key)
		values.append(weight)
		
	var chance = (randf() if not rand else rand.randf()) * total_weight
	
	var total = 0
	for idx in range(len(values)):
		total += values[idx]
		if total >= chance:
			return keys[idx]
	return keys[-1]

static func extend(d1: Dictionary, d2: Dictionary) -> Dictionary:
	"""
	Creates a new dictionary that is the combination of 2 dictionaries
	Similar to object.assign in javascript
	"""
	var out = {}
	for k in d1.keys():
		out[k] = d1[k]
	for k in d2.keys():
		out[k] = d2[k]
	return out
	
static func enumerate_dir(dir: String, extension: Array = [""], recurse: bool = true) -> Array:
	"""
	Fetch a list of files in a directory that match the extension.
	
	Good for when you just want names without loading the actual file.
	"""
	var files: Array[String] = []
	for f in DirAccess.get_files_at(dir):
		for e in extension:
			if e.is_empty() or f.ends_with(e):
				files.append(dir.path_join(f))
		
	if recurse:
		for d in DirAccess.get_directories_at(dir):
			files.append_array(enumerate_dir(dir.path_join(d), extension, recurse))
	
	return files

static func load_dir(resource_dir, ext = ['.tres'], recurse = false) -> Dictionary:
	"""
	Load resource assets from a directory.
	Needed for various factories, such as for Items and Enemies
	
	This uses blocking io and is not suitable for large directories with lots of big files
	"""
	var files = enumerate_dir(resource_dir, ext, recurse)
	return files.reduce(
		func (d, f):
			d[f] = load(f)
			return d,
		{}
	)

static func load_async(path):
	await Engine.get_main_loop().process_frame
	var loader = ResourceLoader.load_threaded_request(path)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await Engine.get_main_loop().process_frame
	
	return ResourceLoader.load_threaded_get(path)
	
static func v32xy(v: Vector3) -> Vector2:
	return Vector2(
		v.x, v.y
	)

static func v32xz(v: Vector3) -> Vector2:
	return Vector2(
		v.x, v.z
	)

static func v32yz(v: Vector3) -> Vector2:
	return Vector2(
		v.y, v.z
	)
	
static func v23xy(v: Vector2) -> Vector3:
	return Vector3(
		v.x, v.y, 0
	)

static func v23yz(v: Vector2) -> Vector3:
	return Vector3(
		0, v.x, v.y
	)
	
static func v23xz(v: Vector2) -> Vector3:
	return Vector3(
		v.x, 0, v.y
	)
