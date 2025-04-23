extends Node2D

@onready var room_name_label = $"Room name"

func _ready() -> void:
	room_name_label.text = SocketOnline.room_name
	
	for players in SocketOnline.players_name: 
		

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
