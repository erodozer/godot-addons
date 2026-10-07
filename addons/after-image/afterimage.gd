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
@export_range(1, 60, 1) var interval: float = 30.0 ## times per second to create an after image (limit 60 FPS)
@export_range(1, 100) var POOL_SIZE = 5 ## Limit the number of after images generated
@export var active = false ## Control if after images should be spawning

# internal pool state
var pool: Array = []
var pool_idx = 0

# internal timer for tracking it's okay to spawn an after image
var spawner: float = 0

func _ready() -> void:
	pool.resize(POOL_SIZE)

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
	
	var t = image.create_tween()
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
		else:
			mi.bake_mesh_from_current_skeleton_pose(node.mesh)
		t.parallel().tween_method(
			func (f):
				node.set_instance_shader_parameter("opacity", f),
			1.0, 0.0, lifetime
		)
	
	image.global_transform = model.global_transform
	pool_idx = wrapi(pool_idx + 1, 0, POOL_SIZE)
	return image

func _process(delta: float) -> void:
	if not active:
		return
	if (spawner + delta) / (1.0 / interval) > 1.0:
		create_image()
	spawner = wrapf(spawner + delta, 0, 1.0 / interval)
