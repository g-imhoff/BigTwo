extends Node2D

func _ready():
	UISounds.install_sounds(self)

func _on_texture_button_pressed() -> void:
		get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
