extends Node3D

@export var player : Node3D
@export var rotation_speed : float = 5.0

var target_rotation : float = 0.0

func _ready() -> void:
	target_rotation = self.rotation_degrees.y

func _physics_process(delta : float) -> void:
	if player != null:
		self.global_position = player.global_position
	self.rotation_degrees.y = lerpf(rotation_degrees.y, target_rotation, rotation_speed * delta)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed(&"camera_left"):
		target_rotation -= 90.0
	elif event.is_action_pressed(&"camera_right"):
		target_rotation += 90.0
