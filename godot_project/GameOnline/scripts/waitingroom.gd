extends Node2D

@onready var room_name_label = $"Room name"
@onready var scroll_bar = $HScrollBar/HBoxContainer
const room_scene_path = "res://GameOnline/scenes/Room.tscn"

func _ready() -> void:
	room_name_label.text = SocketOnline.room_name
	
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
		"send_room":
			_display_room(data["list_room"])

func _display_room(list): 
	var room_scene = preload(room_scene_path)
	for room in list:
		var room_instance = room_scene.instantiate()
		room_instance.set_values(room["room_name"], room["players"].size())
		scroll_bar.add_child(room_instance)
		
