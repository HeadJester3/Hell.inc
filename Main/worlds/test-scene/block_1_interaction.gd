extends MeshInstance3D

const DIALOGUE : DialogueResource = preload("res://core/dialogues/test.dialogue")

func interact() -> void:
	DialogueManager.show_dialogue_balloon(DIALOGUE)
