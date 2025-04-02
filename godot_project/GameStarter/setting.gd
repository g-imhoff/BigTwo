extends Node2D



func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGMusic"), Config.volume_value)


func make_visible(ismenu) -> void:
	self.set_visible(true) 


func _on_button_pressed() -> void:
	get_tree().quit()



func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	Config.volume_value = value  # Modifie la valeur du volume dans le script autoload
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGMusic"), value)
	print(value)


func _on_check_button_music_toggled(toggled_on: bool) -> void:
	if toggled_on==false:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("BGMusic"),true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("BGMusic"),false)
		


func _on_check_button_button_sound_toggled(toggled_on: bool) -> void:
	if toggled_on==false:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sfx"),true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sfx"),false)
