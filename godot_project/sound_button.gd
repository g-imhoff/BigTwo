extends AnimatedSprite2D

func _on_sound_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("SoundButtonClicked")
		
		if frame == 1: 
			frame = 0
		else: 
			frame = 1
