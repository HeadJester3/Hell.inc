extends Node

var dialogues = {}
var current_sequence = []
var index = 0

signal dialogue_started
signal dialogue_updated(text)
signal dialogue_finished

func _ready():
	load_dialogues()

func load_dialogues():
	var file = FileAccess.get_file_as_string("res://data/dialogues.json")
	dialogues = JSON.parse_string(file)

func start_dialogue(id: String):
	if not dialogues.has(id):
		return

	current_sequence = dialogues[id]
	index = 0

	emit_signal("dialogue_started")
	show_current_line()

func show_current_line():
	if index >= current_sequence.size():
		emit_signal("dialogue_finished")
		return

	var line = current_sequence[index]
	emit_signal("dialogue_updated", line["text"])

func next():
	index += 1
	show_current_line()
