extends Character

@export_group("Velocity")
@export var speed : float = 10.0
@export var acceleration : float = 1.0
@export var deceleration : float = 0.40
@export var opposite_deceleration : float = 0.50

@export_group("Attack")
@export var attack_damage : float = 25.0
@export var attack_cooldown : float = 0.5
@export var attack_duration : float = 0.2
@export var attack_speed_multiplier : float = 0.3 
@export var current_weapon : String = "sword"

@export_group("Dodge & Counter")
@export var dodge_window : float = 0.3
@export var counter_window : float = 1.0
@export var counter_multiplier : float = 3.0

@export_group("Stats")
@export var health : float = 200

@onready var interaction_cast : ShapeCast3D = $Body/ShapeCast3D as ShapeCast3D
@onready var attack_area : Area3D = $Body/AttackArea if has_node("Body/AttackArea") else null
@onready var attack_collision : CollisionShape3D = $Body/AttackArea/CollisionShape3D if attack_area else null
@onready var attack_animation : AnimatedSprite3D = $Body/AttackArea/AttackAnimation

var direction : Vector3 = Vector3.ZERO
var attack_target_direction : Vector3 = Vector3.ZERO
var can_attack : bool = true
var is_attacking : bool = false
var target_rotation_y : float = 0.0

var is_dodging : bool = false
var dodge_success : bool = false
var last_dodge_time : float = 0.0


# CALLBACKS
func _ready() -> void:
	# --- ENSURES CAMERA IS LOADED ---
	if camera == null:
		camera = get_viewport().get_camera_3d()
	
	# --- DISABLES HITBOX ON BEGGINING ---
	if attack_collision != null:
		attack_collision.disabled = true

func _physics_process(_delta : float) -> void:
	# --- --- GETS MOVEMENT INPUT AND NORMALIZES DIRECTION RELATIVELY TO CAMERA --- ---
	var input_dir : Vector3 = Vector3(
		Input.get_axis(&"move_left", &"move_right"),
		0.0,
		Input.get_axis(&"move_forward", &"move_back")
	).normalized()
	direction = camera.global_basis * input_dir
	
	
	# --- --- IMPLEMENTS MOVEMENT AND ATTACK --- ---
	
	# --- SETUPS 2D DIRECTION VECTORS. IMPLEMENTS ACCELERATION AND DECELERATION. DETECTS OPPOSITE MOVEMENT AND DECELERATES.---
	if not is_zero_approx(input_dir.length_squared()):
		current_char_state = char_state.WALK
		var horizontal_dir : Vector2 = Vector2(direction.x, direction.z).normalized()
		var current_horizontal_move : Vector2 = Vector2(velocity.x, velocity.z).normalized()
		var is_opposite : bool = false
		
		# --- DETECTS OPPOSITE MOVEMENT AND APPLIES DECELERATION IF SO ---
		if current_horizontal_move.length() > 0.1:
			is_opposite = current_horizontal_move.dot(horizontal_dir) < 0.0
		if is_opposite:
			var deceleration_vect : Vector2 = current_horizontal_move * opposite_deceleration
			velocity.x -= deceleration_vect.x
			velocity.z -= deceleration_vect.y
			
			# ---   ---
			if Vector2(velocity.x, velocity.z).length_squared() <= 0.01:
				velocity.x = 0.0
				velocity.z = 0.0
				
		# --- NORMAl ACCELERATION IF NOT MOVING OPPOSITE DIRECTION ---
		else:
			velocity.x += direction.x * acceleration
			velocity.z += direction.z * acceleration
			var horizontal : Vector2 = Vector2(velocity.x, velocity.z)
			var max_speed : float = speed * (attack_speed_multiplier if is_attacking else 1.0) # Applies attack movement decelaration
			
			if horizontal.length() > max_speed:
				horizontal = horizontal.normalized() * max_speed
				velocity.x = horizontal.x
				velocity.z = horizontal.y
		
		# --- UPDATE TARGET ROTATION ONLY WHEN NOT ATTACKING ---
		if not is_attacking:
			target_rotation_y = atan2(-direction.z, direction.x)
	
	# --- APPLIES DECELARTION WHEN STOPING MOVEMENT  ---
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
		velocity.z = move_toward(velocity.z, 0.0, deceleration)
		current_char_state = char_state.IDLE
	
	body.rotation.y = target_rotation_y
	move_and_slide()
	set_facing_sprite()
	

	# --- --- IMPLEMENTS ACTIONS --- ---
	
	# --- IMPLEMENT INTERACTION (DIALOGUE, FLAVOR TEXT ETC) ---
	if Input.is_action_just_pressed(&"interact") and GameState.flow_state == GameState.NORMAL:
		interact()
		
	# --- EXECUTES ATTACK AND IMPLEMENTS ATTACK DIRECTION BASED ON MOUSE CLICK ---
	if Input.is_action_just_pressed(&"attack") and can_attack:
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var ray_origin : Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_direction : Vector3 = camera.project_ray_normal(mouse_pos)
		var ground_plane : Plane = Plane(Vector3.UP, 0.0)  # plano no chão
		var intersection_point : Vector3 = ground_plane.intersects_ray(ray_origin, ray_direction)
		
		if intersection_point != null:
			var target_dir : Vector3 = (intersection_point - global_position).normalized()
			target_dir.y = 0.0  # IGNORES HEIGHT
			attack_target_direction = target_dir
		else:
			attack_target_direction = -body.global_transform.basis.z # Fallback: keeps current direction

		perform_attack(attack_target_direction)
	
	# --- DODGE (Shift or Ctrl) ---
	if Input.is_action_just_pressed(&"dodge") and not is_attacking and not is_dodging:
		_perform_dodge()


# HANDLERS
func interact() -> void:
	# --- --- UPDATES INTERACTION SHAPECAST AND IMPLEMENTS COLLISION DETECT WITH INTERACTABLE OBJECTS --- ---
	interaction_cast.force_shapecast_update()
	for i : int in range(interaction_cast.get_collision_count()):
		
		var collider : Node = interaction_cast.get_collider(i) as Node
		if collider == self:
			continue
			
		var object : Node = collider.get_parent()
		if object.has_method(&"interact"):
			object.call(&"interact")
			break

func perform_attack(attack_dir : Vector3 = Vector3.ZERO) -> void:
	if not can_attack:
		return
	
	# --- VERIFICA SE É CONTRA-ATAQUE (dano triplicado) ---
	var damage_multiplier : float = 1.0
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if dodge_success and (current_time - last_dodge_time) <= counter_window:
		damage_multiplier = counter_multiplier
		dodge_success = false   # reseta para não usar mais de uma vez
		print("CONTRA-ATAQUE! Dano triplicado!")
	
	var final_damage = attack_damage * damage_multiplier
	
	can_attack = false
	is_attacking = true
	
	# --- SETS ATTACK DIRECTION ---
	if attack_dir == Vector3.ZERO:
		attack_dir = -body.global_transform.basis.z
		attack_dir.y = 0.0
	
	target_rotation_y = atan2(-attack_dir.z, attack_dir.x)
	
	# --- PLAYS ATTACK ANIMATION ONCE ---
	if attack_animation != null:
		attack_animation.visible = true
		attack_animation.sprite_frames.set_animation_loop(current_weapon, false)
		attack_animation.play(current_weapon)
	
	# --- ACTIVATES HITBOX ---
	if attack_collision != null:
		attack_collision.disabled = false
	
	# --- WAITS BEFORE DAMAGE ---
	await get_tree().create_timer(0.15).timeout # Time before applying damage. Used to sync attack animation and damage as desired
	
	# --- APPLIES DAMAGE ---
	_apply_damage_to_enemies(final_damage)
	
	# --- WAITS UNTIL ANIMATION FINISHES ---
	if attack_animation != null:
		await attack_animation.animation_finished
	
	# --- DEACTIVATES HITBOX ---
	if attack_collision != null:
		attack_collision.disabled = true
	
	# --- DEACTIVATES ANIMATION ---
	if attack_animation != null:
		attack_animation.visible = false
		attack_animation.stop()
	
	# --- RELEASES ATTACK STATE ---
	is_attacking = false
	
	# --- WAITS FOR COOLDOWN ---
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func _apply_damage_to_enemies(damage_amount : float = -1.0) -> void:
	if attack_area == null:
		return
	
	# Usa o dano passado ou o padrão
	var damage = attack_damage if damage_amount < 0 else damage_amount
	
	# --- CHECKS IF THERE ARE VALID ENEMIES IN THE ATTACK HITBOX. IF YES, APPLIES DAMAGE ---
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method(&"take_damage"):
			body.take_damage(damage)
		elif body.get_parent() != null and body.get_parent().has_method(&"take_damage"):
			body.get_parent().take_damage(damage)

func _perform_dodge() -> void:
	print("--- ESQUIVA TENTADA ---")
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("Inimigos encontrados no grupo 'enemy': ", enemies.size())
	
	if enemies.size() == 0:
		print("Nenhum inimigo no grupo 'enemy'! Verifique se os inimigos estão no grupo.")
		return
	
	var can_dodge : bool = false
	var enemy_attacking = null
	
	for enemy in enemies:
		print("Verificando inimigo: ", enemy.name, " - is_attacking: ", enemy.is_attacking)
		
		if enemy.is_attacking:
			# Verifica a distância (opcional)
			var distance = global_position.distance_to(enemy.global_position)
			print("Distância até o inimigo: ", distance)
			
			if distance < 5.0:  # ajuste conforme necessário
				can_dodge = true
				enemy_attacking = enemy
				print("Inimigo atacando dentro do alcance!")
				break
			else:
				print("Inimigo atacando, mas muito longe.")
		else:
			print("Inimigo não está atacando.")
	
	if not can_dodge:
		print("Esquiva falhou: nenhum inimigo atacando dentro do alcance.")
		return
	
	# --- EXECUTA A ESQUIVA ---
	print("Esquiva bem-sucedida contra: ", enemy_attacking.name)
	is_dodging = true
	dodge_success = true
	last_dodge_time = Time.get_ticks_msec() / 1000.0
	
	can_attack = true
	
	await get_tree().create_timer(0.2).timeout
	is_dodging = false
	
func take_damage(amount : float) -> void:
	# --- --- CHECKS IF PLAYER IS DODGING --- ---
	if is_dodging or dodge_success:
		print("Dano ignorado: player está esquivando!")
		# Reseta a flag para não ser usada novamente
		dodge_success = false
		return
		
	else:
		print("Player sofreu ", amount, " de dano!")
		CameraShake.shake(0.2, 0.6)
		health -= amount
		
	if health <= 0:
		die()
		
func die() -> void:
	print("Player morreu!")
