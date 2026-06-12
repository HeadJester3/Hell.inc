extends CharacterBody3D

@export_group("Character Nodes")
@export var body : Node3D
@export var sprites : AnimatedSprite3D

@export_group("Velocity")
@export var speed : float = 10.0
@export var acceleration : float = 2.5
@export var deceleration : float = 0.25

@export_group("Animations")
@export_subgroup("Idle")
@export var idle_front : StringName = &"idle_front"
@export var idle_back : StringName = &"idle_back"
@export var idle_right : StringName = &"idle_right"
@export var idle_left : StringName = &"idle_left"

var direction : Vector3 = Vector3(0.0, 0.0, 0.0)

@onready var camera : Camera3D = $CameraRig/Camera3D as Camera3D

func _physics_process(_delta : float) -> void:
	var input_dir : Vector3 = Vector3(
			Input.get_axis(&"move_left", &"move_right"), 0.0,
			Input.get_axis(&"move_forward", &"move_back")
	).normalized()
	direction = camera.global_basis * input_dir

	if not is_zero_approx(input_dir.length_squared()):
		velocity.x += direction.x * acceleration
		velocity.z += direction.z * acceleration
		var horizontal : Vector2 = Vector2(velocity.x, velocity.z)
		body.rotation.y = atan2(-direction.z, direction.x)

		if horizontal.length() > speed:
			horizontal = horizontal.normalized() * speed
			velocity.x = horizontal.x
			velocity.z = horizontal.y
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)

	move_and_slide()
