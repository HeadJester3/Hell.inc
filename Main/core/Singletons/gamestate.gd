extends Node

enum {
	NORMAL, #0
	GLOBAL_PAUSED, #1
	IN_MENU, #2
	INVENTORY, #3
	SAVE_MENU, #4
	OPTIONS_MENU, #5
	DIALOGUE, #6
	SCENE_CHANGE #7
}

var flow_state : int = 0
var current_dialogue_participants : int = 3
var has_talked_to_TheWoman : bool = true
var has_prism : bool = false
