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
