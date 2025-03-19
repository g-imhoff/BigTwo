extends Node2D

var socket = WebSocketPeer.new()

const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
var center_screen_x

func _on_tree_exited() -> void:
	socket.close()

func _ready() -> void:
	var clientCAS = load("res://cert.crt")
	var err = socket.connect_to_url(Global.server_url, TLSOptions.client_unsafe(clientCAS))
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		while socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			socket.poll()
			await get_tree().create_timer(0.1).timeout # Small delay to prevent CPU overload
		_server_handshake()

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN: 
		while socket.get_available_packet_count():
			_data_received_handler(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func _data_received_handler(data):
	match int(data["code"]):
		0:
			# Connected to the server game
			pass
		1: 
			_card_hand_init(data["card_hand"], data["first_player"])

func _server_handshake():
	var content = JSON.stringify({
		"function": "connect",
		"profile_name": Global.username
	})
	
	socket.send_text(content)

func _card_hand_init(list_card, bool_first_player):
	center_screen_x=get_viewport().size.x/2
	var card_scene=preload(CARD_SCENE_PATH)
	for card in list_card: 
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		
		var new_texture=load(card)
		var card_info = Global.get_card_info_from_texture(card)
		new_card.value = card_info[1]
		new_card.form = card_info[0]
		new_card.name="Card"
		sprite.texture=new_texture
		$"../card_manager".add_child(new_card)
