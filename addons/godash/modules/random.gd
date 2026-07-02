extends Object

enum SELECT_CHOICE { KEY, VALUE }


## Pick randomly out of a collection.
## [br]
## Has more control than the built-in random function on arrays.
## Uses a supplied RandomNumberGenerator instead of being tied to the global random seed
static func choice(collection, select:SELECT_CHOICE = SELECT_CHOICE.VALUE, rand: RandomNumberGenerator = null):
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

## Select a random key from a dictionary based on percentage chances defined for each key.
static func chance(collection: Dictionary, rand: RandomNumberGenerator = null):
	
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
