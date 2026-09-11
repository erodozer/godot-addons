extends Object

## Reduces an array to only its unique values
static func unique(collection: Array) -> Array:
	var d = {}
	for i in collection:
		d[i] = true
	return d.keys()

## Creates a new dictionary that is the combination of 2 dictionaries. Similar to object.assign in javascript
static func extend(d1: Dictionary, d2: Dictionary) -> Dictionary:
	var out = {}
	for k in d1.keys():
		out[k] = d1[k]
	for k in d2.keys():
		out[k] = d2[k]
	return out

## Creates a new Array based on the elements found to be present in both provided Arrays
static func intersect(a: Array, b: Array) -> Array:
	var out = []
	for x in a:
		if x in b:
			out.append(x)
	return out

## fetch values from nested dictionaries using dot-path traversal
static func path(dict: Dictionary, key: String, defaultValue: Variant = null) -> Variant:
	var levels = key.split(".")
	var level = levels[0]
	
	if len(levels) > 1:
		if dict.get(level) is Dictionary:
			return path(dict.get(level), ".".join(levels.slice(1)), defaultValue)
		return defaultValue
	var found = dict.get(level, defaultValue)
	if found == null:
		return defaultValue
	return found

## determine if a nested dictionary contains a key by its dot-path
static func has_path(dict: Dictionary, key: String) -> bool:
	var levels = key.split(".")
	var level = levels[0]
	
	if len(levels) > 1:
		if dict.get(level) is Dictionary:
			return has_path(dict.get(level), ".".join(levels.slice(1)))
		return false
	return level in dict

## fetch against multiple dictionaries, returning the first found value
static func get_deep(dicts: Array[Dictionary], key: String, defaultValue: Variant):
	for i in dicts:
		if has_path(i, key):
			return path(i, key, defaultValue)
	return defaultValue
