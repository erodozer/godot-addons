## Copy MeshInstance3D instances to create an after image effect
## 
## Creates an after image effects of models by copying instances on a set interval.
## Only MeshInstance3D nodes are recursively copied, and require consistently unique names from the path
## that they are copied from. A special shader effect is applied to each instance, and the after image
## meshes take the shape of the baked skeleton pose.
## [br]
## Instances are pooled and their meshes updated instead of being added to the scene tree each time.
## This creates a bounded memory allocation and limits scene tree thrashing.
class_name AfterImage extends Node

const shader = preload("./afterimage_material.gdshader")

@export var clone: NodePath ## path to the instance that will be referenced for copying.  Only children of type MeshInstance3D are copied into the after image
@export_range(0.1, 3.0, 0.01) var lifetime = 0.2 ## Duration that an after image persists/takes to fade away
@export_range(0.01, 3.0, 0.01) var frequency: float = 0.05 ## rate in sec to create an afterimage
@export_range(1, 100) var pool_size = 5 : ## Limit the number of after images generated
	set = set_pool_size
		
@export var active = false ## Control if after images should be spawning

# internal pool state
var pool: Array = []
var pool_idx = 0

# internal timer for tracking it's okay to spawn an after image
var spawner: float = 0

func _ready() -> void:
	set_pool_size(pool_size)

func set_pool_size(size: int):
	pool_size = size
	pool.clear()
	pool.resize(size)
	for i in get_children():
		remove_child(i)
		i.queue_free()	

func activate():
	active = true
	spawner = 0
	
func deactivate():
	active = false
	
## Drain the pool and free existing after images
func reset():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	pool.clear()
	pool_idx = 0

func create_image() -> Node3D:
	var model: Node3D = get_node(clone)
	var image: Node3D
	if pool.get(pool_idx) != null:
		image = pool.get(pool_idx)
	else:
		image = Node3D.new()
		add_child(image)
		pool[pool_idx] = image
	
	var now = Time.get_ticks_msec()
	image.global_transform = model.global_transform
	image.scale = Vector3.ONE * 0.99
	image.set_meta("lifetime", Vector2(now, now + (1000.0 * lifetime)))
	
	# Wait for end of frame so we don't have to stall the rendering server while
	# baking the meshes of each visual instance
	await RenderingServer.frame_post_draw
	
	for mi_n in model.find_children("*", "MeshInstance3D", true, false):
		var mi = mi_n as MeshInstance3D
		var node = image.find_child(mi_n.name, false, false)
		if node == null:
			node = mi.duplicate()
			node.name = mi_n.name
			image.add_child(node)
			for s in range(mi.mesh.get_surface_count()):
				var mat: ShaderMaterial = mi.get_active_material(s)
				var image_mat = ShaderMaterial.new()
				image_mat.shader = shader
				image_mat.set_shader_parameter("albedo_texture", mat.get_shader_parameter("albedo_texture"))
				node.set_surface_override_material(s, image_mat)
			node.mesh = mi.bake_mesh_from_current_skeleton_pose()
			node.sorting_offset = -1
			node.sorting_use_aabb_center = true
		else:
			mi.bake_mesh_from_current_skeleton_pose(node.mesh)
			mi.transparency = 0
	
	pool_idx = wrapi(pool_idx + 1, 0, pool_size)
	return image

func _fade(amount: float, node: MeshInstance3D):
	node.transparency = amount

func _process(delta: float) -> void:
	var now = Time.get_ticks_msec()
	for i in range(pool_size):
		var after_image = pool[i]
		if not after_image:
			continue
		var spawn = after_image.get_meta("lifetime")
		if now > spawn.y and not active:
			after_image.queue_free()
			pool[i] = null
			continue
		for mesh in after_image.get_children():
			mesh.transparency = clamp(
				inverse_lerp(spawn.x, spawn.y, now),
				0.0, 1.0
			)
	
	if not active:
		return
	
	if (spawner + delta) > frequency:
		create_image()
	spawner = wrapf(spawner + delta, 0, frequency)
