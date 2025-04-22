extends Node2D


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")


func _on_create_room_btn_pressed() -> void:
	$Createroompop.visible = not $Createroompop.visible


func _on_join_room_btn_pressed() -> void:
	$Joinroompop.visible = not $Joinroompop.visible
