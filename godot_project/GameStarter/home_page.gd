extends Node2D

func _ready() -> void:
	# Activer les sons UI sur tous les boutons de cette scène
	UISounds.install_sounds(self)

# Function called when an input event (e.g., mouse click) is detected on the user button.
# _viewport: The viewport node associated with the event.
# event: The detected input event (e.g., mouse click).
# _shape_idx: The shape index in the case of a collision shape node.
func _on_user_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("UserButtonClicked")

# Function called when an input event is detected on the rules button.
# _viewport: The viewport node associated with the event.
# event: The detected input event.
# _shape_idx: The shape index in the case of a collision shape node.
func _on_rules_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		get_tree().change_scene_to_file("res://GameStarter/RulesPage.tscn")

# Function called when the "Play Now" button is pressed.
func _on_play_now_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ConnectionPage.tscn")

# Function called when an input event is detected on the Instagram button.
# _viewport: The viewport node associated with the event.
# event: The detected input event.
# _shape_idx: The shape index in the case of a collision shape node.
func _on_instagram_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("InstagramButtonClicked")

func _on_texture_button_2_pressed() -> void:
		get_tree().change_scene_to_file("res://GameStarter/RulesPage.tscn") 

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGMusic"), value)
