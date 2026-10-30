## MultiMeshInstance3D Baker
##
## Inspector addon to [MultiMeshInstance3D] that provides a utility function to bake
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
@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is MultiMeshInstance3D

func _parse_category(object: Object, category: String) -> void:
	if category != "MultiMeshInstance3D":
		return
		
	var layout = FlowContainer.new()
	layout.alignment = FlowContainer.ALIGNMENT_CENTER
	
	var baker = Button.new()
	baker.text = "Bake Multimesh"
	baker.icon = EditorInterface.get_editor_theme().get_icon("PreviewSun", "EditorIcons")
	baker.pressed.connect(bake.bind(object))
	baker.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.add_child(baker, true)
	
	var restorer = Button.new()
	restorer.text = "Deinstance"
	restorer.icon = EditorInterface.get_editor_theme().get_icon("Duplicate", "EditorIcons")
	restorer.pressed.connect(restore.bind(object))
	restorer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.add_child(restorer, true)
	
	var instancer = Button.new()
	instancer.text = "Add Instance"
	instancer.icon = EditorInterface.get_editor_theme().get_icon("Add", "EditorIcons")
	instancer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	instancer.pressed.connect(add_instance.bind(object))
	layout.add_child(instancer, true)

	add_custom_control(layout)
	
	add_custom_control(HSeparator.new())

func bake(mmi: MultiMeshInstance3D) -> void:
	# get all mesh instances and lift them into multimesh
	var found: Array = mmi.find_children("*", "MeshInstance3D", true, false)
	assert(len(found) > 0, "must have at least one Mesh present to bake with")
	
	var multi: MultiMesh = MultiMesh.new()
	
	multi.transform_format = MultiMesh.TRANSFORM_3D

	var i: int = 0
	if mmi.multimesh != null:
		# copy existing transforms into the new mesh
		var existing = mmi.multimesh.instance_count
		multi.instance_count = len(found) + existing
		for instance in existing:
			multi.set_instance_transform(instance, mmi.multimesh.get_instance_transform(instance))
		i = existing
	else:
		multi.instance_count = len(found)
	
	multi.mesh = found[0].mesh
	
	assert(multi.mesh != null, "must have at least one Mesh present to bake with")
		
	for f in found:
		assert(f.mesh == multi.mesh, "More than one mesh detected in children, unable to bake.")
		var t: Transform3D = mmi.global_transform.affine_inverse() * f.global_transform
		multi.set_instance_transform(i, t)
		i += 1
	
	if not Engine.is_editor_hint():
		mmi.multimesh = multi
	else:
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Bake MultiMesh3D")
		undo_redo.add_do_property(mmi, "multimesh", multi)
		if mmi.multimesh:
			undo_redo.add_undo_reference(mmi.multimesh)
		undo_redo.add_undo_property(mmi, "multimesh", mmi.multimesh)
		for c in mmi.get_children():
			undo_redo.add_do_method(mmi, "remove_child", c)
			undo_redo.add_undo_reference(c)
			undo_redo.add_undo_method(mmi, "add_child", c)
			undo_redo.add_undo_method(c, "set_owner", EditorInterface.get_edited_scene_root())
		undo_redo.commit_action()

## Converts the MultiMesh back into [MeshInstance3D] nodes in the scene tree, allowing for manual placement in the editor.
## Since MultiMesh only stores Mesh instances, it is unable to completely recover the original
## tree structure if baked from a PackedScene.
func restore(mmi: MultiMeshInstance3D) -> void:
	assert(mmi.multimesh != null, "Can only restore from an existing multimesh.")
	assert(mmi.multimesh.instance_count <= 1000, "Preventing deinstancing of too many nodes into the scene tree.  Has drastic impact to performance.")
	
	var instances = []
	for i in mmi.multimesh.instance_count:
		var instance = MeshInstance3D.new()
		instance.mesh = mmi.multimesh.mesh
		instance.transform = mmi.multimesh.get_instance_transform(i)
		instances.append(instance)
		
	if not Engine.is_editor_hint():
		for i in instances:
			mmi.add_child(i)
		mmi.multimesh = null
	else:
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Bake MultiMesh3D")
		undo_redo.add_do_property(mmi, "multimesh", null)
		undo_redo.add_undo_property(mmi, "multimesh", mmi.multimesh)
		
		for i in instances:
			undo_redo.add_do_method(mmi, "add_child", i, true)
			undo_redo.add_do_method(i, "set_owner", EditorInterface.get_edited_scene_root())
			undo_redo.add_do_reference(i)
			undo_redo.add_undo_method(mmi, "remove_child", i)
		undo_redo.commit_action()

func add_instance(mmi: MultiMeshInstance3D) -> void:
	assert(mmi.multimesh != null, "Can only add an instance from an existing multimesh")
	assert(mmi.multimesh.mesh != null, "Can only add an instance from a set mesh")
	
	var instance = MeshInstance3D.new()
	instance.mesh = mmi.multimesh.mesh
	mmi.add_child(instance, true)
