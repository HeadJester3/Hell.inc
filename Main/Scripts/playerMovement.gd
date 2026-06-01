extends CharacterBody3D
@export var speed := 5.0

func _physics_process(delta):
	var input_dir = Vector2.ZERO

	input_dir.y = Input.get_axis("move_left", "move_right")
	input_dir.z = Input.get_axis("move_forward", "move_back")

	var direction = Vector3(
		input_dir.x,
		0,
		input_dir.z
	).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
