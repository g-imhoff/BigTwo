extends Node2D

@onready var room_name_label = $"Room name"

func _ready() -> void:
	room_name_label.text = SocketOnline.room_name
