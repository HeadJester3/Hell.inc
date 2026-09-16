extends Node2D

@onready var background = $Fundo
@onready var underlay = $Underlay
@onready var control = $Control
@onready var buttons = [
	$Control/MarginContainer/VBoxContainer/Continue,
	$Control/MarginContainer/VBoxContainer/Save,
	$Control/MarginContainer/VBoxContainer/Options,
	$Control/MarginContainer/VBoxContainer/Quit
]
@onready var markers = [
	$Control/MarginContainer/VBoxContainer/Continue/Marker2D,
	$Control/MarginContainer/VBoxContainer/Save/Marker2D,
	$Control/MarginContainer/VBoxContainer/Options/Marker2D,
	$Control/MarginContainer/VBoxContainer/Quit/Marker2D
]
@onready var option_lines = [
	$OptionLine1,
	$OptionLine2,
	$OptionLine3,
	$OptionLine4
]

@export var speed: float = 1000.0
@export var hole_width: float = 0.05
@export var hole_height: float = 0.03
@export var image_path_a: String = "res://core/images/menu_layerA.png"
@export var image_path_b: String = "res://core/images/menu_layerB.png"
@export var selected_texture: String = "res://core/images/menu_optionline_selected.png"

var selected_index = 0
var current_pos = Vector2.ZERO
var target_pos = Vector2.ZERO
var is_moving = false
var is_initialized = false
var original_textures = []
var original_colors = []




# CALLBACKS
func _ready() -> void:
	# --- TEXTURE LOAD AND MOUSE IGNORING ---
	var tex_a = load(image_path_a)
	var tex_b = load(image_path_b)

	underlay.texture = tex_a
	underlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = tex_b
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# --- SHADER LOAD AND CONFIG (PARAMETERS) ---
	var mat = ShaderMaterial.new()
	var shader_res = load("res://core/shaders/buraco_menu.gdshader")

	if shader_res == null:
		print("ERROR: shader not found!")
		return

	mat.shader = shader_res
	mat.set_shader_parameter("texture_a", tex_a)
	mat.set_shader_parameter("texture_b", tex_b)
	mat.set_shader_parameter("hole_width", hole_width)
	mat.set_shader_parameter("hole_height", hole_height)
	background.material = mat
	await get_tree().process_frame # Waits 1 frame to let the sizes load

	# --- ORIGINAL OPTIONS TEXTURES SAVING ---
	original_textures.clear()
	for sprite in option_lines:
		if sprite != null:
			original_textures.append(sprite.texture)
		else:
			original_textures.append(null)
			print("WARNING: OptionLine sprite not found!")

	original_colors.clear()
	for b in buttons:
		if b != null:
			original_colors.append(b.get_theme_color("font_color"))
		else:
			original_colors.append(Color.WHITE)
			print("WARNING: Button not found!")

	# --- SQUARE STARTING POSITION ---
	var marker = markers[0]
	if marker != null:
		current_pos = marker.global_position
		target_pos = current_pos
		update_hole()
		is_initialized = true
		update_textures()  # applies selection to the first option
	else:
		print("ERROR: Marker not found!")

	# --- BUTTONS CONFIGURATION ---
	for b in buttons:
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.pressed.connect(_on_button_pressed.bind(b))

	print("Menu started. Use W/S to navigate.")

func _input(event: InputEvent) -> void:

	# --- IMPLEMENTS W/S NAVIGATION USING THE MARKERS AS TARGETS ---
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_W or event.keycode == KEY_UP:
			if selected_index > 0:
				selected_index -= 1
				target_pos = markers[selected_index].global_position
				is_moving = true
				print("Selected: ", buttons[selected_index].text)

		# --- IMPLEMENTS UP ARROW/DOWN ARROW NAVIGATION. ANALOGUE. ---
		elif event.keycode == KEY_S or event.keycode == KEY_DOWN:
			if selected_index < buttons.size() - 1:
				selected_index += 1
				target_pos = markers[selected_index].global_position
				is_moving = true
				print("Selected: ", buttons[selected_index].text)

func _process(delta: float) -> void:
	if background.material == null or not is_initialized:
		return

	var diff : Vector2 = target_pos - current_pos

	if diff.length() < 0.1:
		current_pos = target_pos
		if is_moving:
			is_moving = false
			update_textures()   # only changes when stopped
	else:
		var step := speed * delta
		if step > diff.length():
			current_pos = target_pos
		else:
			current_pos += diff.normalized() * step

	update_hole()

func _on_button_pressed(button: Button) -> void:
	print("Clicked: ", button.text)
	match button.text:
		"Continue":
			print("Continue game")
		"Save":
			print("Save game")
		"Options":
			print("Options")
		"Quit":
			print("Quit")



# HANDLERS
func update_hole() -> void:
	if background.material == null:
		return
	var uv := Vector2(
		current_pos.x / background.size.x,
		current_pos.y / background.size.y
	)
	uv.x = clamp(uv.x, 0.0, 1.0)
	uv.y = clamp(uv.y, 0.0, 1.0)
	background.material.set_shader_parameter("hole_center", uv)

func update_textures() -> void:
	if not is_initialized:
		return

	var tex_sel = load(selected_texture)

	for i in range(option_lines.size()):
		var sprite = option_lines[i]
		if sprite == null:
			continue

		if i == selected_index:
			sprite.texture = tex_sel
		else:
			if i < original_textures.size() and original_textures[i] != null:
				sprite.texture = original_textures[i]

		var botao = buttons[i]
		if botao != null:
			if i == selected_index:
				botao.add_theme_color_override("font_color", Color.RED)
			else:
				if i < original_colors.size():
					botao.add_theme_color_override("font_color", original_colors[i])
