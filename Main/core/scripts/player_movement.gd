extends CharacterBody3D 

@onready var camera : Camera3D = $CameraRig/Camera3D as Camera3D 
@export var speed : float = 10.0
@export var accelerationspd : float = 2.5
@export var decelerationspd : float = 0.25 
var direction : Vector3 = Vector3(0.0, 0.0, 0.0) 


func _physics_process(_delta : float) -> void: 

	var input_dir : Vector2 = Vector2(
		Input.get_axis(&"move_left", &"move_right"),
		Input.get_axis(&"move_forward", &"move_back")
	) 
	var forward : Vector3 = camera.global_basis.z.normalized() 
	var right : Vector3 = camera.global_basis.x.normalized()
	direction = (forward * input_dir.y + right * input_dir.x).normalized()

	if input_dir.length() > 0.0: 
		velocity.x += direction.x * accelerationspd 
		velocity.z += direction.z * accelerationspd 
		var horizontal = Vector2(velocity.x, velocity.z) 

		if horizontal.length() > speed: 
			horizontal = horizontal.normalized() * speed
			velocity.x = horizontal.x
			velocity.z = horizontal.y

	else:
		velocity.x = move_toward(velocity.x, 0, decelerationspd)
		velocity.z = move_toward(velocity.z, 0, decelerationspd)

	move_and_slide()
