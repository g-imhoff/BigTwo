extends Node2D

@onready var room_name_label = $"Room name"
@onready var scroll_bar = $HBoxContainer
@onready var cancel_btn = $"Cancel Btn"
@onready var create_btn = $"Start Btn"

func _ready() -> void:
	room_name_label.text = SocketOnline.room_name
	_update_players_connected()
	
	if (Global.username == SocketOnline.host_name): 
		cancel_btn.visible = true
		create_btn.visible = true

func _update_players_connected(): 
	for child in scroll_bar.get_children():
		child.queue_free()
	
	for players in SocketOnline.players_name: 
		var label = Label.new()
		label.text = players
		scroll_bar.add_child(label)

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
		"new_connection": 
			SocketOnline.players_name = data["players"]
			_update_players_connected()
		"starting": 
			SocketOnline.id = data["id"]
			SocketOnline.card_hand = data["card_hand"]
			SocketOnline.first_player = data["first_player"]
			SocketOnline.list_id = data["list_id"]
			get_tree().change_scene_to_file("res://GameOnline/scenes/ClientGame.tscn")

func _on_start_btn_pressed() -> void:
	if SocketOnline.players_name.size() == 4: 
		var message = JSON.stringify({
			"function": "start_game",
			"room_name": SocketOnline.room_name
		})
		
		SocketOnline.socket.send_text(message)
	else: 
		Notification.show_side("Wait for the server to be full!")


func _on_cancel_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameOnline/scenes/Lobby.tscn")
