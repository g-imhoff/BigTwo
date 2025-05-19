extends Node2D

const room_scene_path = "res://GameOnline/scenes/Room.tscn"
@onready var scroll_bar = $HBoxContainer

func _on_cancel_btn_pressed() -> void:
	$".".visible = not $".".visible

func display_room(list): 
	var room_scene = preload(room_scene_path)
	for room in list:
		var room_instance = room_scene.instantiate()
		scroll_bar.add_child(room_instance)  # Add first
		await get_tree().process_frame  # Wait for next frame
		room_instance.set_values(room["room_name"], int(room["players"]))  # Now safe
