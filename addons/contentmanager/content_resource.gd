## Type of Resource that can be managed by ContentManager
## these resources exist in categorical subfolders within the `res://content` directory
@abstract extends Resource
class_name ContentResource

@export var _id: String

@abstract func category()

func editor():
	return EditorInspector.new()

func _validate_property(property: Dictionary):
	if property.name in ["resource_path", "resource_local_to_scene", "resource_name"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		property.hint = PROPERTY_HINT_NONE
	if property.name == "resource":
		property.usage = PROPERTY_USAGE_INTERNAL
