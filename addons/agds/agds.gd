## Advanced Global Dispatch System
##
## @author erodozer <ero@erodozer.moe>
## [br][br]
## Singleton EventBus with topic routing (similar to RabbitMQ)
## Listeners can be bound using simple patterns with wildcard support against message types
extends Node

var topics: Dictionary[String, Dictionary] = {}

func _ready() -> void:
	set_process_internal(true)
	
func _match_topic(pattern: String, topic: String):
	if pattern == "*":
		return true
		
	var i = 0
	var n = 0
	var wildcard = false
	while n < len(topic):
		if pattern[i] == "*":
			wildcard = true
			i += 1
			if i >= len(pattern):
				break
		if topic[n] == pattern[i]:
			wildcard = false
			n += 1
			i += 1
		elif wildcard:
			n += 1
		else:
			return false
			
	return wildcard or (i == len(pattern) and n == len(topic))

func register(listener: Callable, topic: String = "*"):
	var group: Dictionary = topics.get(topic, {})
	group[listener] = true
	topics[topic] = group

func unregister(listener: Callable, topic: String = "*"):
	topics.get(topic, {}).erase(listener)

## Invokes all callables with a pattern matching the type
func dispatch(topic: String, message: Variant):
	for key in topics:
		if not _match_topic(key, topic):
			continue
		for handler in topics.get(key, {}).keys():
			var h = handler as Callable
			if h.is_valid():
				handler.call(message)

## does a pass through all registered listeners and cleans up any callable bindings that are no longer valid
func cleanup():
	var update: Dictionary[String, Dictionary] = {}
	for key in topics:
		var valid: Dictionary = {}
		for handler in topics.get(key, {}).keys():
			var h = handler as Callable
			if h.is_valid():
				valid[handler] = true
		if not valid.is_empty():
			update[key] = valid
	topics = update

func _notification(what: int) -> void:
	if what == NOTIFICATION_INTERNAL_PROCESS:
		cleanup()
