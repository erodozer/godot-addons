## BakeableMultiMeshInstance3D
##
## Specialized MultiMeshInstance3D that provides a utility function to bake
## manually placed [MeshInstance3D] with the same [Mesh] into an optimized
## [MultiMesh].  Mesh instances are extracted recursively from children with transforms
## preserved.
## This allows for using a [PackedScene], which may contain collision data and other details,
## and convert them into simple visual instances for use in decorating.
## It is required that all children prior to baking utilize the same Mesh resource due to
## the nature of MultiMesh.  If a multimesh has already been baked and you add more children,
## when rebaking those children will be added into the existing multimesh.
## [br][br]
## This tool exists to allow you to manually define where each instance is placed instead of relying on
## scatter randomness, enabling a more hand-crafted visual intent while
## reaping the performance benefits of render batches.
@tool class_name BakeableMultiMeshInstance3D extends MultiMeshInstance3D

@export_tool_button("Bake Multimesh") var baker = bake
@export_tool_button("Unbake Multimesh") var restorer = restore

func bake() -> void:
	# get all mesh instances and lift them into multimesh
	var found: Array = self.find_children("*", "MeshInstance3D", true, false)
	assert(len(found) > 0, "must have at least one Mesh present to bake with")
	
	var multi: MultiMesh = MultiMesh.new()
	
	multi.transform_format = MultiMesh.TRANSFORM_3D

	var i: int = 0
	if self.multimesh != null:
		# copy existing transforms into the new mesh
		var existing = self.multimesh.instance_count
		multi.instance_count = len(found) + existing
		for instance in existing:
			multi.set_instance_transform(instance, self.multimesh.get_instance_transform(instance))
		i = existing
	else:
		multi.instance_count = len(found)
	
	multi.mesh = found[0].mesh
	
	assert(multi.mesh != null, "must have at least one Mesh present to bake with")
		
	for f in found:
		assert(f.mesh == multi.mesh, "More than one mesh detected in children, unable to bake.")
		var t: Transform3D = global_transform.affine_inverse() * f.global_transform
		multi.set_instance_transform(i, t)
		i += 1
	
	if not Engine.is_editor_hint():
		self.multimesh = multi
	else:
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Bake MultiMesh3D")
		undo_redo.add_do_property(self, "multimesh", multi)
		undo_redo.add_undo_property(self, "multimesh", self.multimesh)
		for c in get_children():
			undo_redo.add_do_method(self, "remove_child", c)
			undo_redo.add_undo_reference(c)
			undo_redo.add_undo_method(self, "add_child", c)
			undo_redo.add_undo_method(c, "set_owner", EditorInterface.get_edited_scene_root())
		undo_redo.commit_action()

## Converts the MultiMesh back into [MeshInstance3D] nodes in the scene tree, allowing for manual placement in the editor.
## Since MultiMesh only stores Mesh instances, it is unable to completely recover the original
## tree structure if baked from a PackedScene.
func restore() -> void:
	assert(self.multimesh != null, "Can only restore from an existing multimesh")
	
	var instances = []
	for i in self.multimesh.instance_count:
		var instance = MeshInstance3D.new()
		instance.mesh = multimesh.mesh
		instance.transform = multimesh.get_instance_transform(i)
		instances.append(instance)
		
	if not Engine.is_editor_hint():
		for i in instances:
			add_child(i)
		self.multimesh = null
	else:
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Bake MultiMesh3D")
		undo_redo.add_do_property(self, "multimesh", null)
		undo_redo.add_undo_property(self, "multimesh", self.multimesh)
		
		for i in instances:
			undo_redo.add_do_method(self, "add_child", i, true)
			undo_redo.add_do_method(i, "set_owner", EditorInterface.get_edited_scene_root())
			undo_redo.add_do_reference(i)
			undo_redo.add_undo_method(self, "remove_child", i)
		undo_redo.commit_action()

func _detect_mesh() -> Array[Mesh]:
	var mi: Array = self.find_children("*", "MeshInstance3D", true, false)
	var meshes: Dictionary[Mesh, bool] = mi.reduce(
		func (acc, mi):
			acc[mi.mesh] = true
			return acc,
		{} as Dictionary[Mesh, bool]
	)
	return meshes.keys()

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
	
	if what == Node.NOTIFICATION_CHILD_ORDER_CHANGED:
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	var meshes = _detect_mesh()
	
	if not meshes.is_empty():
		if len(meshes) != 1:
			warnings.append("Only 1 unique mesh may be present for baking")
		elif len(meshes) == 1:
			var mesh = meshes[0]
			if multimesh != null and multimesh.mesh and not (mesh == multimesh.mesh or mesh.resource_path == multimesh.mesh.resource_path):
				print([mesh.resource_path, multimesh.mesh.resource_path])
				warnings.append("A child mesh does not match existing mesh, baking will overwrite the reference")
	return warnings
