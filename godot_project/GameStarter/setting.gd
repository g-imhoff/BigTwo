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
