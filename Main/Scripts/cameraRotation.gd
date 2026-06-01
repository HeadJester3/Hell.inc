extends Node3D
@export var rotation_speed := 8.0

var target_rotation := 45.0

func _ready():
	rotation_degrees.y = target_rotation

func _input(event):
	if event.is_action_pressed("camera_left"):
		target_rotation -= 90

	if event.is_action_pressed("camera_right"):
		target_rotation += 90

func _process(delta):
	rotation_degrees.y = lerp_angle(
		rotation_degrees.y,
		target_rotation,
		rotation_speed * delta
	)
