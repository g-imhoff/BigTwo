extends Node2D


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Game/scenes/main.tscn")


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
