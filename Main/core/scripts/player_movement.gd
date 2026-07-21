extends CharacterBody3D

@onready var camera : Camera3D = $CameraRig/Camera3D as Camera3D
@onready var interaction_cast : ShapeCast3D = $Body/ShapeCast3D

@export_group("Character Nodes")
@export var body : Node3D
@export var sprites : AnimatedSprite3D

@export_group("Velocity")
@export var speed : float = 10.0
@export var acceleration : float = 2.5
@export var deceleration : float = 0.40
@export var opposite_deceleration : float = 0.50

@export_group("Animations")
@export_subgroup("Idle")
@export var idle_front : StringName = &"idle_front"
@export var idle_back : StringName = &"idle_back"
@export var idle_right : StringName = &"idle_right"
@export var idle_left : StringName = &"idle_left"

var direction : Vector3 = Vector3.ZERO




# CALLBACKS 
func _physics_process(_delta : float) -> void:
	
	# --- MOVEMENT ---
	var input_dir : Vector3 = Vector3(
		Input.get_axis(&"move_left", &"move_right"),
		0.0,
		Input.get_axis(&"move_forward", &"move_back")
	).normalized()
	direction = camera.global_basis * input_dir

	if not is_zero_approx(input_dir.length_squared()):
		var horizontal_dir : Vector2 = Vector2(direction.x, direction.z).normalized()
		var current_horizontal_move : Vector2 = Vector2(velocity.x, velocity.z).normalized()

		var is_opposite : bool = false
		if current_horizontal_move.length() > 0.1:
			is_opposite = current_horizontal_move.dot(horizontal_dir) < 0.0
		if is_opposite:
			var deceleration_vect : Vector2 = current_horizontal_move * opposite_deceleration
			velocity.x -= deceleration_vect.x
			velocity.z -= deceleration_vect.y
			if Vector2(velocity.x, velocity.z).length_squared() <= 0.01:
				velocity.x = 0.0
				velocity.z = 0.0
		else:
			velocity.x += direction.x * acceleration
			velocity.z += direction.z * acceleration
			var horizontal : Vector2 = Vector2(velocity.x, velocity.z)
			if horizontal.length() > speed:
				horizontal = horizontal.normalized() * speed
				velocity.x = horizontal.x
				velocity.z = horizontal.y

		body.rotation.y = atan2(-direction.z, direction.x)

	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
		velocity.z = move_toward(velocity.z, 0.0, deceleration)

	move_and_slide()
	
	
	
	# --- INTERACTIONS ---
	if Input.is_action_just_pressed("interact") and GameState.flow_state == 0:
		interact()



# HANDLERS 
func interact() -> void:
	interaction_cast.force_shapecast_update()

	for i : int in range(interaction_cast.get_collision_count()):
		var collider : Object = interaction_cast.get_collider(i)

		if collider == self:
			continue

		var object : Node = collider.get_parent()

		if object.has_method("interact"):
			object.interact()
			return
