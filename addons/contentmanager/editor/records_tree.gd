@tool
extends Tree

func _get_drag_data(at_position: Vector2) -> Variant:
	var tree_item: TreeItem
	if at_position == Vector2.INF:
		tree_item = get_selected()
	else:
		tree_item = get_item_at_position(at_position)
	var content: ContentResource = tree_item.get_metadata(0)
	if content.resource_path == "":
		return null

	var label = Label.new()
	label.text = tree_item.get_text(0)
	set_drag_preview(label)

	# use inspector drag format so you can drop resources
	# into standard inspector edit fields
	return {
		"type": "resource",
		"resource": content
	}
