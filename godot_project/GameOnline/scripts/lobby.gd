extends Node2D

@onready var join_room = $Background/Joinroompop

func _ready() -> void:
	if SocketOnline.socket.get_ready_state()!= WebSocketPeer.STATE_OPEN:
		var err = SocketOnline.socket.connect_to_url(Global.server_url)
		if err != OK:
			print("Unable to connect")
			set_process(false)
	else:
		while SocketOnline.socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			SocketOnline.socket.poll()
			await get_tree().create_timer(0.1).timeout # Small delay to prevent CPU overload

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
		"send_room":
			join_room.display_room(data["list_room"])
		"room_connection_failed": 
			Notification.show_side(data["reason"])
		"room_connected": 
			SocketOnline.room_name = data["room_name"]
			SocketOnline.players_name = data["players"]
			SocketOnline.host_name = data["host_name"]
			get_tree().change_scene_to_file("res://GameOnline/scenes/Waitingroom.tscn")

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")

func _on_create_room_btn_pressed() -> void:
	$Background/Createroompop.visible = not $Background/Createroompop.visible

func _on_join_room_btn_pressed() -> void:
	var message = JSON.stringify({
		"function": "get_room"
	})
	
	SocketOnline.socket.send_text(message)
	$Background/Joinroompop.visible = not $Background/Joinroompop.visible
