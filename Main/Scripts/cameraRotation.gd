extends Node3D

@export var player: Node3D
@export var rotation_speed := 5.0
var target_rotation := 0.0

func _ready():
	target_rotation = rotation_degrees.y

func _process(delta):
	if player:
		global_position = player.global_position

	rotation_degrees.y = lerp(
		rotation_degrees.y,
		target_rotation,
		rotation_speed * delta
	)

func _input(event):
	
#tale vo come sua alma 
	if event.is_action_pressed("camera_left"):
		target_rotation -= 90.0

	if event.is_action_pressed("camera_right"):
		target_rotation += 90.0
