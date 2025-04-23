extends Node2D


func _on_settings_btn_pressed() -> void:
	$Setting.visible = not $Setting.visible


func _on_texture_button_pressed() -> void:
	$Rules_Popup.visible = not $Rules_Popup.visible
