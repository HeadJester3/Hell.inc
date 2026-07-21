extends Node3D

@onready var camera : Camera3D = $Camera3D
@onready var player_body : Node3D = player.get_node("Body")
@onready var ray : RayCast3D = $Camera3D/RayCast3D  

@export_group("Character Nodes")
@export var player : Node3D

@export_group("RayCasting Settings")
@export var rotation_speed : float = 5.0
@export var obstruction_alpha : float = 0.3
@export var fade_smoothness : float = 8.0

const HALF_PI : float = PI / 2.0
var target_rotation : float = 0.0
var faded_mesh : MeshInstance3D = null
var original_materials : Array = []
var current_alpha : float = 1.0
var target_alpha : float = 1.0

 



# CALLBACKS
func _ready() -> void:
	target_rotation = self.global_rotation.y

func _input(event : InputEvent) -> void:
	if event.is_action_pressed(&"camera_left"):
		target_rotation -= HALF_PI
	elif event.is_action_pressed(&"camera_right"):
		target_rotation += HALF_PI

func _physics_process(delta : float) -> void:
	# --- CAMERA POSITION ---
	self.global_position = player.global_position
	self.global_rotation.y = lerp_angle(global_rotation.y, target_rotation, rotation_speed * delta)

	# --- OBSTRUCTION DETECTION ---
	update_obstruction_fade(delta)



# HANDLERS
func update_obstruction_fade(delta : float) -> void:
	var new_mesh : MeshInstance3D = null
	
	# --- RAY POITING (from camera to player) --
	ray.global_position = camera.global_position 
	ray.target_position = ray.to_local(player_body.global_position)
	ray.force_raycast_update()

	# --- COLLISION CHECK WITH RAY --
	if ray.is_colliding():
		var collider : Object = ray.get_collider()
		var current : Node = collider
		
		while current != null and not current is MeshInstance3D: #Makes sure current  is a Meshinstance
			current = current.get_parent()
		new_mesh = current as MeshInstance3D

	# --- PREVIOUS FADED MESH AND NEW MESH SWAP --
	if new_mesh != faded_mesh:
		if faded_mesh != null:
			restore_materials(faded_mesh)
			faded_mesh = null
		if new_mesh != null:
			store_and_make_transparent(new_mesh)
			faded_mesh = new_mesh

	target_alpha = obstruction_alpha if faded_mesh != null else 1.0
	current_alpha = lerp(current_alpha, target_alpha, fade_smoothness * delta)

	if faded_mesh != null:
		update_mesh_alpha(faded_mesh, current_alpha)

func store_and_make_transparent(mi : MeshInstance3D) -> void:
	original_materials.clear()
	for i : int in range(mi.mesh.get_surface_count()):
		var mat : Material = mi.get_surface_override_material(i)
		if mat == null:
			mat = mi.mesh.surface_get_material(i)
		var new_mat : BaseMaterial3D = mat.duplicate() if mat != null and mat is BaseMaterial3D else null
		if new_mat != null:
			new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			new_mat.albedo_color.a = 1.0
			mi.set_surface_override_material(i, new_mat)
		original_materials.append(mat)
	current_alpha = 1.0
	target_alpha = obstruction_alpha
	
func restore_materials(mi : MeshInstance3D) -> void:
	for i : int in range(mi.mesh.get_surface_count()):
		mi.set_surface_override_material(i, original_materials[i] if i < original_materials.size() else null)
	original_materials.clear()

func update_mesh_alpha(mi : MeshInstance3D, alpha : float) -> void:
	for i : int in range(mi.mesh.get_surface_count()):
		var mat : Material = mi.get_surface_override_material(i)
		if mat is BaseMaterial3D:
			mat.albedo_color.a = alpha
