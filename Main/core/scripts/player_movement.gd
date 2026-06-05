extends CharacterBody3D

var direction : Vector3

@export var speed : float = 5.0
@onready var camera : Camera3D = $CameraRig/Camera3D

func _physics_process(_delta : float) -> void:
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_back")
	)
	var forward : Vector3 = camera.global_basis.z.normalized()
	var right : Vector3 = camera.global_basis.x.normalized()
	direction = (forward * input_dir.y + right * input_dir.x).normalized()
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
