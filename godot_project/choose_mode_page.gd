extends Node2D

func _on_single_player_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("SinglePlayerClicked")


func _on_multi_player_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("MultiPlayerClicked")
