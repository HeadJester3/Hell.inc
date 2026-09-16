extends Node

# ============================================================
# CONFIGURAÇÕES
# ============================================================

var camera : Camera3D = null
var shake_intensity : float = 0.0
var shake_duration : float = 0.0
var shake_timer : float = 0.0
var original_position : Vector3 = Vector3.ZERO
var is_shaking : bool = false

# ============================================================
# MÉTODOS PÚBLICOS
# ============================================================

func shake(duration : float = 0.2, intensity : float = 0.3) -> void:
	if camera == null:
		camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	
	shake_duration = duration
	shake_intensity = intensity
	shake_timer = duration
	is_shaking = true
	original_position = camera.position

# ============================================================
# CICLO DE VIDA
# ============================================================

func _process(delta : float) -> void:
	if not is_shaking or camera == null:
		return
	
	shake_timer -= delta
	
	if shake_timer <= 0.0:
		# Finaliza o shake
		camera.position = original_position
		is_shaking = false
		shake_intensity = 0.0
		return
	
	# Aplica deslocamento aleatório
	var intensity = shake_intensity * (shake_timer / shake_duration)  # fade out
	var offset = Vector3(
		randf_range(-1.0, 1.0) * intensity,
		randf_range(-1.0, 1.0) * intensity,
		0.0
	)
	camera.position = original_position + offset
