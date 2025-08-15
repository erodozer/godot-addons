## Type of Resource that can be managed by ContentManager
## these resources exist in categorical subfolders within the `res://content` directory
@tool
extends Resource
class_name ContentResource

func category():
	push_error("Category not defined, unable to associate resource")

func editor():
	return EditorInspector.new()

func _validate_property(property: Dictionary):
	if property.name in ["resource_path", "resource_local_to_scene"]:
		property.usage = PROPERTY_USAGE_INTERNAL
		property.hint = PROPERTY_HINT_NONE
	if property.name == "resource":
		property.usage = PROPERTY_USAGE_INTERNAL
	
