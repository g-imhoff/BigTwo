extends AnimatedSprite2D

@onready var password = $"../../../../.."
func _on_area_2d_input_event_2(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		if password.password_line_edit.is_secret():
			password.password_line_edit.set_secret(false)
		else:
			password.password_line_edit.set_secret(true)
			
		if frame == 1: 
			frame = 0
		else: 
			frame = 1
