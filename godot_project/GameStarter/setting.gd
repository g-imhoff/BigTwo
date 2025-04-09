extends Node2D

@onready var slider = $"PopupSettings/vol bar"
@onready var musicbtn = $"PopupSettings/music btn"
@onready var soundbtn = $"PopupSettings/sound btn"


func _ready():
	slider.value = Config.volume_value
	musicbtn.toggle_mode = Config.music_check
	soundbtn.toggle_mode = Config.button_check 
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
		Config.music_check = false
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("BGMusic"),false)
		Config.music_check = true
		


func _on_check_button_button_sound_toggled(toggled_on: bool) -> void:
	if toggled_on==false:
		Config.button_check=false
	else:
		Config.button_check=true 
