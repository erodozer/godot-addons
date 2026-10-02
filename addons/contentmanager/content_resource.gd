## Type of Resource that can be managed by ContentManager
## these resources exist in categorical subfolders within the `res://content` directory
@abstract extends Resource
class_name ContentResource

var _id: String :
	get:
		if resource_path:
			return resource_path.get_file().get_basename()
		return "<NEW>"

@abstract func category()

func editor_icon() -> Texture2D:
	return preload("res://addons/contentmanager/editor/icons/Shape2D.svg")

func editor():
	return EditorInspector.new()

func _validate_property(property: Dictionary):
	if "resource" in property.name:
		property.usage |= ~PROPERTY_USAGE_NO_EDITOR
