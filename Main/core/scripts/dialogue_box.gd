extends PanelContainer

# --- LAYOUT CONSTANTS ---
const OUTER_OFFSET : float = 10.0   # Distance from outer edge to first layer
const LAYER_GAP : float = 20.0      # Thickness of the gap between each rectangle
const INNER_MARGIN : float = 6.0    # Extra breathing room for text inside the last layer
@export var num_layers : int = 6    # How many layers to draw (set by GlobalState)

# --- COLOR CONSTANTS ---
# Outer layer will be Brunette Brown. Inner layer will be Black.
const COLOR_END := Color(0.545, 0.271, 0.075) # Brunette Brown (RGB: 139, 69, 19)
const COLOR_START := Color(0.0, 0.0, 0.0)         # Black (RGB: 0, 0, 0)


func _draw() -> void:
	var layer_thickness : float = LAYER_GAP / num_layers

	# Calculate the available drawing area based on the PanelContainer's size
	var total_width = size.x - 2.0 * OUTER_OFFSET
	var total_height = size.y - 2.0 * OUTER_OFFSET
	var x_offset = OUTER_OFFSET
	var y_offset = OUTER_OFFSET

	# Draw the layered rectangles from outer to inner
	for i : int in range(num_layers):
		# Calculate the percentage of progress through the layers (0.0 to 1.0)
		var progress : float = 1.0 if num_layers == 1 else float(i) / float(num_layers - 1)
		
		# Lerp (interpolate) the color based on the progress
		var current_color := COLOR_START.lerp(COLOR_END, progress)

		# Draw the current rectangle
		draw_rect(
			Rect2(
				x_offset + i * layer_thickness,
				y_offset + i * layer_thickness,
				total_width - 2.0 * i * layer_thickness,
				total_height - 2.0 * i * layer_thickness
			),
			current_color
		)

	# Draw the final innermost border (the inner "empty" space) in pure black
	draw_rect(
		Rect2(
			x_offset + LAYER_GAP,
			y_offset + LAYER_GAP,
			total_width - 2.0 * LAYER_GAP,
			total_height - 2.0 * LAYER_GAP
		),
		COLOR_END
	)

	# Apply the calculated margins so the text stays perfectly inside the last layer
	_update_container_margins()


func _update_container_margins() -> void:
	# Calculate exactly how much space the colored layers take up
	var total_layer_shrink = LAYER_GAP + (num_layers - 1) * (LAYER_GAP / num_layers)
	
	# The text container needs margins equal to the outer offset + the shrink + breathing room
	var final_margin = OUTER_OFFSET + total_layer_shrink + INNER_MARGIN
	
	# Find the inner MarginContainer that holds the text and force it to sit inside the last layer
	var inner_margin_container = $MarginContainer
	if inner_margin_container:
		inner_margin_container.add_theme_constant_override("margin_left", final_margin)
		inner_margin_container.add_theme_constant_override("margin_right", final_margin)
		inner_margin_container.add_theme_constant_override("margin_top", final_margin)
		inner_margin_container.add_theme_constant_override("margin_bottom", final_margin)


# This function allows the script to change the layer count mid-game
func set_layer_count(new_count: int) -> void:
	num_layers = new_count
	queue_redraw()


func _process(_delta: float) -> void:
	# Constantly redraw to ensure the background updates if the UI resizes
	queue_redraw()
