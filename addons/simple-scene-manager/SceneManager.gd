extends Node
class_name SimpleSceneManager
## Simplify complex scene management with safe memory transitioning
## and threaded loading of Nodes.
##
## This library is designed to supercede usage of Godot's built-in 
## current_scene functionality that is baked into the SceneTree.[br]
## SceneManager introduces additional lifecycle hooks that are useful
## for Scenes that extend the functionality of Godot's own Node lifecycle.
## These new hooks are fully optional methods and allow for activity
## tied to when scenes load, unload, and transition into focus.
## 
## [br][br]
## Order of hooks
## [codeblock]
## - _tree_entered
## - _ready
## - _setup (async)
##  (fade out)
## - _start (async)
## - _teardown (async)
##  (fade in)
## - _tree_exited
## [/codeblock]
##
## As noted, for added convenience all the new lifecycle nodes that scenes have allow for coroutines.
## This allows for non-blocking processing and loading screens.
## [br]
## To use SceneManager, it is recommended to add SceneManager.tscn to your project's Autoload.
## It has built-in behavior to work with single scene testing as well, so that all lifecycle hooks
## can be properly evoked, as long as the scene is properly tagged with the group name of "scene".
## [br]
## If you wish to customize SceneManager, such as the dither texture, animation speed, or more,
## it is recommended to create an InstancedScene derived from the SceneManager.tscn, and then
## assign that to your AutoLoad.[br]
## [br]
## @author: Erodozer <ero@erodozer.moe> [br]
## @version: 3.0.0 [br]
## @godot_version: [min 4.0] [br]

## Signal emitted after scene _setup hook has been completed
signal setup
## Signal emitted after scene _start hook has been completed
signal started
## Signal emitted after scene _teardown hook has been completed
signal teardown

func _ready():
	# remove and readd current scene to guarantee intro
	# lifecycle hooks
	var s = get_tree().current_scene
	if s.is_in_group("scene"):
		await s.get_parent().ready # wait until scene is fully ready
		change_scene(s)

## Changes scene with a transition.
## You can hold the fade back in transition if desired until
## the next scene is in a state that is considered ready
##
## Parameters passed in are fed into the _setup lifecycle hook
func change_scene(next_scene, params=[]):
	get_tree().paused = true
	
	var anim = %AnimationPlayer
	var current_scene = get_tree().current_scene
	if current_scene != null:
		if current_scene.has_method("_teardown"):
			await current_scene._teardown()
			
		teardown.emit()
			
		if (next_scene is Node and current_scene != next_scene) or not (next_scene is Node):
			anim.play("Fade")
			await anim.animation_finished
	
	if next_scene is String:
		# if a scene node is passed through, like with debugging,
		# we only need to fade in.  Else we're loading the scene
		next_scene = next_scene if next_scene.begins_with("res://") else "res://scenes/%s/scene.tscn" % next_scene
		var loader = ResourceLoader.load_threaded_request(next_scene)
		var res = null
		while res == null:
			match ResourceLoader.load_threaded_get_status(next_scene):
				ResourceLoader.THREAD_LOAD_LOADED:
					res = ResourceLoader.load_threaded_get(next_scene)
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					continue
				_:
					assert(false, "Failed to load scene, this should never happen")
					return false
				
		get_tree().change_scene_to_packed(res)
	elif next_scene is Node:
		get_tree().current_scene = next_scene

		if current_scene != next_scene:
			current_scene.queue_free()
		
		current_scene = next_scene
		next_scene.request_ready()
	else:
		get_tree().change_scene_to_packed(next_scene)
		
	await get_tree().process_frame
	current_scene = get_tree().current_scene
	if current_scene.has_method("_setup"):
		await current_scene._setup(params)
		
	setup.emit()
	
	anim.play_backwards("Fade")
	await anim.animation_finished
	
	get_tree().paused = false
	
	if current_scene.has_method("_start"):
		await current_scene._start()
		
	started.emit()
