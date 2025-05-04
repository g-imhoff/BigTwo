extends Node2D

func _ready():
	UISounds.install_sounds(self)

	# Set previously selected avatar if any
	if GlobalAvatar.selected_character_texture != null:
		$AvatarImage.texture = GlobalAvatar.selected_character_texture

	# Dynamically connect all TextureButtons in AvatarPopup
	for button in $AvatarPopup/PopupSettings.get_children():
		if button is TextureButton:
			button.pressed.connect(_on_avatar_button_pressed.bind(button))

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")

func _on_change_avatar_pressed() -> void:
	$AvatarPopup.visible = not $AvatarPopup.visible

func _on_avatar_button_pressed(button: TextureButton) -> void:
	GlobalAvatar.selected_character_texture = button.texture_normal
	$AvatarImage.texture = button.texture_normal
	$AvatarPopup.hide()


func _on_disconnect_pressed() -> void:
	SaveData.clear_all_saves()
	Global.username = ""
	Global.email = ""
	Global.connection_token = ""
	Global.remaining_data.username = ""
	Global.remaining_data.connection_token = ""
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
