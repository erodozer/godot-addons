extends Object

## queues all children of a node to be free.
## This implicitly means all nested children also get freed.
## You can await this procedure which will pause a coroutine
## until the end of the frame to make sure the node is emptied
static func clear_node(root: Node):
	while root.get_child_count() > 0:
		for i in root.get_children():
			i.queue_free()
		await root.get_tree().process_frame

## Recursively walk through all nodes in a tree, executing  a supplied callable against each encountered node
## If you plan on walking nodes on an unchanging tree frequently, it's recommended to use filter_nodes and cache the results.
static func walk_nodes(root: Node, callable: Callable) -> void:
	for i in root.get_children():
		callable.call(i)
		
	for i in root.get_children():
		if i.get_child_count() > 0:
			walk_nodes(i, callable)

## Recursively grabs all nodes within a tree that match a predicate (Callable[Node, Boolean])
static func filter_nodes(root: Node, predicate: Callable) -> Array:
	var selected = []
	walk_nodes(
		root,
		func (node: Node):
			if predicate.call(node):
				selected.append(node)
	)
	return selected

# fitlers nodes by class name
static func get_nodes_by_type(root: Node, node_type: StringName) -> Array:
	return filter_nodes(
		root,
		func (node):
			return node.is_class(node_type)
	)

## Specialized version of get_nodes_in_group, where we filter to only those within the subtree
## of the provided node.  Works outside of the scene tree
static func get_nodes_in_group(root: Node, group: String) -> Array[Node]:
	return filter_nodes(
		root,
		func (node:Node):
			return node.is_in_group(group)
	)
