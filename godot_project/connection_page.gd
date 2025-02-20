extends Node2D

func _on_login_button_pressed() -> void:
	get_tree().change_scene_to_file("res://LoginPage.tscn")


func _on_register_button_pressed() -> void:
	get_tree().change_scene_to_file("res://CreatePage.tscn")
