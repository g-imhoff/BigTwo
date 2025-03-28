extends Node2D

func make_visible(ismenu) -> void:
	self.set_visible(true) 


func _on_button_pressed() -> void:
	get_tree().quit()
