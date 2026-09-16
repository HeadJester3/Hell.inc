extends Character

@export var max_health : float = 100.0
@export var current_health : float = 100.0

@export_group("Movement")
@export var movement_type : int = 0
@export var wander_radius : float = 5.0
@export var wander_speed : float = 2.0
@export var change_interval : float = 2.0

@export_group("Attack")
@export var attack_damage : float = 15.0
@export var attack_windup : float = 1.0
@export var attack_cooldown : float = 2.0
@export var attack_range : float = 2.0   # distância máxima para iniciar ataque
@export var current_weapon : String = "normal"

@onready var health_bar : ProgressBar = $HealthBar if has_node("HealthBar") else null
@onready var attack_area : Area3D = $Body/AttackArea if has_node("Body/AttackArea") else null
@onready var attack_collision : CollisionShape3D = $Body/AttackArea/CollisionShape3D if attack_area else null
@onready var attack_animation : AnimatedSprite3D = $Body/AttackArea/AttackAnimation if has_node("Body/AttackArea/AttackAnimation") else null

var target_position : Vector3 = Vector3.ZERO
var wander_timer : float = 0.0
var is_moving : bool = false

var is_attacking : bool = false
var can_attack : bool = true
var player_ref : Node3D = null


# CALLBACKS
func _ready() -> void:
	add_to_group("enemy") 
	
	current_health = max_health
	target_position = global_position
	wander_timer = randf_range(0.0, change_interval)
	
	if movement_type == 1:
		is_moving = true
		_escolher_novo_alvo()
	
	if attack_collision != null:
		attack_collision.disabled = true
	
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref == null:
		print("ERRO: Player não encontrado no grupo 'player'!")
	print("attack_animation: ", attack_animation)  # deve mostrar [AnimatedSprite3D:...]

func _physics_process(delta : float) -> void:
	# --- VERIFICA SE O PLAYER ESTÁ NO ALCANCE PARA INICIAR ATAQUE ---
	if player_ref != null and not is_attacking and can_attack:
		var distance = global_position.distance_to(player_ref.global_position)
		if distance <= attack_range:
			_start_attack()
	
	# --- MOVIMENTO (só se não estiver atacando) ---
	if not is_attacking:
		if movement_type == 1 and is_moving:
			var direction_to_target = (target_position - global_position).normalized()
			velocity.x = direction_to_target.x * wander_speed
			velocity.z = direction_to_target.z * wander_speed
			
			if global_position.distance_to(target_position) < 0.5:
				_escolher_novo_alvo()
			
			wander_timer -= delta
			if wander_timer <= 0.0:
				_escolher_novo_alvo()
				wander_timer = change_interval
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()
	set_facing_sprite()

# HANDLERS
func _escolher_novo_alvo() -> void:
	var angle : float = randf_range(0.0, TAU)
	var distance : float = randf_range(0.0, wander_radius)
	
	var offset : Vector3 = Vector3(
		cos(angle) * distance,
		0.0,
		sin(angle) * distance
	)
	
	target_position = global_position + offset

func take_damage(amount : float) -> void:
	current_health -= amount
	print("Inimigo sofreu ", amount, " de dano. Vida restante: ", current_health)
	
	CameraShake.shake(0.15, 0.4)
	
	if health_bar != null:
		health_bar.value = current_health / max_health * 100.0
	
	if current_health <= 0.0:
		die()

func die() -> void:
	print("Inimigo morreu!")
	queue_free()

func _start_attack() -> void:
	if not can_attack or is_attacking:
		return
	
	is_attacking = true
	can_attack = false
	
	print("Inimigo começou a preparar ataque!")
	
	_start_visual_feedback()
	
	await get_tree().create_timer(attack_windup).timeout
	
	# --- VERIFICA SE O PLAYER AINDA ESTÁ NO ALCANCE ---
	if player_ref != null:
		var distance = global_position.distance_to(player_ref.global_position)
		if distance <= attack_range:
			# --- TOCA A ANIMAÇÃO DE ATAQUE ---
			if attack_animation != null:
				print("Tocando animação de ataque!")
				attack_animation.visible = true
				attack_animation.sprite_frames.set_animation_loop(current_weapon, false)
				attack_animation.play(current_weapon)
			else:
				print("attack_animation é null!")
			
			if attack_collision != null:
				attack_collision.disabled = false
			
			await get_tree().create_timer(0.2).timeout
			
			_apply_damage_to_player()
			
			if attack_animation != null:
				await attack_animation.animation_finished
			
			if attack_collision != null:
				attack_collision.disabled = true
			
			if attack_animation != null:
				attack_animation.visible = false
				attack_animation.stop()
		else:
			print("Ataque cancelado: player saiu do alcance.")
	
	_reset_visual_feedback()
	
	is_attacking = false
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _apply_damage_to_player() -> void:
	if player_ref != null and player_ref.has_method("take_damage"):
		player_ref.take_damage(attack_damage)
		print("Inimigo causou ", attack_damage, " de dano no player!")

func _start_visual_feedback() -> void:
	if sprites != null:
		sprites.modulate = Color(1.0, 0.3, 0.3, 1.0)
		sprites.scale = Vector3(1.2, 1.2, 1.2)

func _reset_visual_feedback() -> void:
	if sprites != null:
		sprites.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sprites.scale = Vector3(1.0, 1.0, 1.0)
