extends MeshInstance3D

var dialogue := preload("res://core/dialogues/teste.dialogue")

func interact() -> void:
	print("BLOCK INTERACTED")
	GameState.current_dialogue_participants = 4
	GameState.flow_state = 6
	DialogueManager.show_dialogue_balloon(dialogue)
