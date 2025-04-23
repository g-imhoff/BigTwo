extends Node2D


func _on_cancel_btn_pressed() -> void:
	$".".visible = not $".".visible
