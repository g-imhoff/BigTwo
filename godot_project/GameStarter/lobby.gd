extends Node2D


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")
