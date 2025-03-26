extends Node2D

func _ready():
	UISounds.install_sounds(self)

func _on_single_player_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("SinglePlayerClicked")
		get_tree().change_scene_to_file("res://Game/main.tscn")


func _on_multi_player_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("MultiPlayerClicked")
		get_tree().change_scene_to_file("res://Game/main.tscn")


func _on_backicon_choose_mode_page_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
