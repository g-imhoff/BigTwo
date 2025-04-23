extends Node2D


func _on_cancel_btn_pressed() -> void:
	$".".visible = not $".".visible

func _ready() -> void:
	var message = JSON.stringify({
		"function": "get_room"
	})
	
	SocketOnline.socket.send_text(message)
