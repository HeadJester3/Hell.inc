extends CharacterBody3D

@export var speed : float = 10.0
@export var sprites : AnimatedSprite3D
@export var accelerationspd : float = 2.5
@export var decelerationspd : float = 0.40
@export var opposite_decelerationspd : float = 0.50
@export var body : Node3D
@onready var camera : Camera3D = $CameraRig/Camera3D as Camera3D

var direction : Vector3 = Vector3.ZERO


func _physics_process(_delta : float) -> void:
	var input_dir : Vector3 = Vector3(
		Input.get_axis(&"move_left", &"move_right"),
		0.0,
		Input.get_axis(&"move_forward", &"move_back")
	).normalized()
	direction = camera.global_basis * input_dir.normalized()
	var horizontal_dir : Vector2 = Vector2(direction.x, direction.z).normalized()
	var has_input : bool = not is_zero_approx(input_dir.length_squared())
	
	if has_input:
		var current_horizontal_move : Vector2 = Vector2(velocity.x, velocity.z).normalized()
		var current_horizontal_speed : float = current_horizontal_move.length()
		print(current_horizontal_speed)
		print("Runtime speed value: ", speed)
		
		var is_opposite : bool = false
		if current_horizontal_speed > 0.1:
			var dot : float = current_horizontal_move.dot(horizontal_dir)
			is_opposite = dot < 0.0
		
		if is_opposite:
			var decelerationspd_vect : Vector2 = current_horizontal_move * opposite_decelerationspd
			velocity.x -= decelerationspd_vect.x
			velocity.z -= decelerationspd_vect.y
			
			var new_vel : Vector2 = Vector2(velocity.x, velocity.z)
			if new_vel.length_squared() <= 0.01:
				velocity.x = 0.0
				velocity.z = 0.0
			
			body.rotation.y = atan2(-direction.z, direction.x)

		else:
			velocity.x += direction.x * accelerationspd
			velocity.z += direction.z * accelerationspd
			
			var horizontal : Vector2 = Vector2(velocity.x, velocity.z)
			if horizontal.length() > speed:
				horizontal = horizontal.normalized() * speed
				velocity.x = horizontal.x
				velocity.z = horizontal.y
			
			body.rotation.y = atan2(-direction.z, direction.x)
		
	else:
		velocity.x = move_toward(velocity.x, 0.0, decelerationspd)
		velocity.z = move_toward(velocity.z, 0.0, decelerationspd)
	
	move_and_slide()
