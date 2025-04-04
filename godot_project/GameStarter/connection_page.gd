extends Node2D

func _ready():
	UISounds.install_sounds(self)

func _on_login_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/LoginPage.tscn")


func _on_register_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/CreatePage.tscn")


func _on_backicon_connection_page_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
