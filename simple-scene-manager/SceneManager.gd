"""
SceneManager.gd
@author Erodozer <ero@erodozer.moe>
@description |>
	Simplify complex scene management with safe memory transitioning
	and dynamic loading of Node.  Scenes are the primary composition of a
	game's stateful context.  
	SceneManager introduces additional lifecycle hooks that are useful
	for Scenes that extend the functionality of Godot's own Node lifecycle.
	These new hooks are fully optional methods and allow for activity
	tied to when scenes load, unload, and transition into focus.
"""
extends Node
class_name SceneManager

@onready var anim = %AnimationPlayer
@onready var container = %Scene

var current_scene
var is_active = false

signal setup
signal started

func _ready():
	if container.get_child_count() == 0:
		# force wait until current scene is ready
		await get_tree().process_frame
		var s = get_tree().current_scene
		if s.is_in_group("scene"):
			s.get_parent().remove_child(s)
			change_scene(s)
	else:
		change_scene(container.get_child(0))

static func change_scene(next_scene, params=[]):
	Engine.get_main_loop().get_nodes_in_group('scene_manager')[0]._change_scene(next_scene, params)

func _change_scene(next_scene, params=[]):
	"""
	Changes scene with a transition.
	You can hold the fade back in transition if desired until
	the next scene is in a state that is considered ready
	"""
	get_tree().paused = true
	is_active = true
	
	anim.play("Fade")
	await anim.animation_finished
	
	var scene = current_scene
	if scene != null:
		if scene.has_method("_teardown"):
			await scene._teardown()
		await get_tree().process_frame
		scene.queue_free()
		await scene.tree_exited
	
	if next_scene is String:
		"""
		if a scene node is passed through, like with debugging,
		we only need to fade in.  Else we're loading the scene
		"""
		next_scene = next_scene if next_scene.begins_with("res://") else "res://scenes/%s/scene.tscn" % next_scene
		var res = await ResourceLoader.load(next_scene)
		current_scene = res.instantiate()
	elif next_scene is Node:
		current_scene = next_scene
	else:
		current_scene = next_scene.instantiate()
		
	container.add_child(current_scene)
		
	if current_scene.has_method("_setup"):
		await current_scene._setup(params)
		
	setup.emit()
	
	anim.play_backwards("Fade")
	await anim.animation_finished
	
	get_tree().paused = false
	
	if current_scene.has_method("_start"):
		await current_scene._start()
		
	started.emit()
	
	is_active = false
