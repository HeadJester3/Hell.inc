extends CharacterBody3D 

@export var speed : float = 5.0
@export var sprites : AnimatedSprite3D
@export var accelerationspd : float = 2.5
@export var decelerationspd : float = 0.25
@export var body : Node3D
@onready var camera : Camera3D = $CameraRig/Camera3D as Camera3D 

var direction : Vector3 = Vector3(0.0, 0.0, 0.0) 

func _physics_process(_delta : float) -> void:
	var input_dir : Vector3 = Vector3(
			Input.get_axis(&"move_left", &"move_right"), 0.0,
			Input.get_axis(&"move_forward", &"move_back")
	).normalized()
	direction = camera.global_basis * input_dir.normalized()

	if not is_zero_approx(input_dir.length_squared()):
		velocity.x += direction.x * accelerationspd
		velocity.z += direction.z * accelerationspd
		var horizontal : Vector2 = Vector2(velocity.x, velocity.z)
		body.rotation.y = atan2(-direction.z, direction.x)

		if horizontal.length() > speed:
			horizontal = horizontal.normalized() * speed
			velocity.x = horizontal.x
			velocity.z = horizontal.y
	else:
		velocity.x = move_toward(velocity.x, 0, decelerationspd)
		velocity.z = move_toward(velocity.z, 0, decelerationspd)

	move_and_slide()
