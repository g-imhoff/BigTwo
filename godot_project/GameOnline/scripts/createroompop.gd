extends Node2D

@onready var room_name_form = $LobbyPopUp/RoomName
@onready var password_form = $LobbyPopUp/Password

var HasH = load("res://hashage.gd")

func _on_cancel_btn_pressed() -> void:
	$".".visible = not $".".visible

func _on_create_btn_pressed() -> void:
	var password_hashed = HasH.hash_password(password_form.text)
	
	var content = JSON.stringify({
		"function": "create_room",
		"host_name": Global.username,
		"room_name": room_name_form.text,
		"password": password_hashed
	})
	
	SocketOnline.socket.send_text(content)
	
func _process(_delta):
	SocketOnline.socket.poll()
	var state = SocketOnline.socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN: 
		while SocketOnline.socket.get_available_packet_count():
			_data_received_handler(JSON.parse_string(SocketOnline.socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = SocketOnline.socket.get_close_code()
		var reason = SocketOnline.socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
		get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")

func _data_received_handler(data):
	match data["function"]:
		"room_created": 
			SocketOnline.room_name = data["room_name"]
			get_tree().change_scene_to_file("res://GameOnline/scenes/Waitingroom.tscn")
