extends Node2D


func _on_lets_play_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ConnectionPage.tscn")
	# need to add a function if you are connected go to choose mode if not go to connection page


func _on_backicon_rules_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
