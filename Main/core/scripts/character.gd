extends CharacterBody3D
class_name Character

enum char_state {
	IDLE,
	WALK,
}

@export var animations : Dictionary[int, Array] = {
	0 : [&"idle_front", &"idle_back", &"idle_right", &"idle_left"],
	1 : [&"walk_front", &"walk_back", &"walk_right", &"walk_left"],
}
@export_group("Character Nodes")
@export var body : Node3D
@export var sprites : AnimatedSprite3D

var current_char_state : int = 0
var camera : Camera3D

func wrap_four(value : float) -> int:
	value = (value - (TAU * floorf((value + PI) / TAU))) / 1.57079632679 # TAU/4, 4 dir. em rad
	return roundi(value - (4.00 * floorf((value - -2.00) / 4.00)))

func set_facing_sprite() -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
		return
	match wrap_four(body.rotation.y - camera.global_rotation.y):
		0:
			sprites.animation = animations.get(current_char_state, animations[0])[2]
		2, -2:
			sprites.animation = animations.get(current_char_state, animations[0])[3]
		-1:
			sprites.animation = animations.get(current_char_state, animations[0])[0]
		1:
			sprites.animation = animations.get(current_char_state, animations[0])[1]
		_:
			sprites.animation = animations.get(current_char_state, animations[0])[0]
