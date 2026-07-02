extends MeshInstance3D

const DIALOGUE := preload("res://core/dialogues/test.dialogue")

func interact() -> void:
	print("BLOCK INTERACTED")
	DialogueManager.show_dialogue_balloon(DIALOGUE)
