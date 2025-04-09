extends Node2D

var socket = WebSocketPeer.new()

const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
var card_scale=Vector2(0.5,0.5)

@onready var hand = $PlayerHand
@onready var enemyhandleft = $EnemyHandLeft
@onready var enemyhandup = $EnemyHandUp
@onready var enemyhandright = $EnemyHandRight
@onready var cardslotleft = $Cardslots3
@onready var cardslotup = $Cardslots2
@onready var cardslotright = $Cardslots4

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
	print(data)
	match data["function"]:
		"connected":
			# Connected to the server game
			pass
		"starting": 
			hand._card_hand_init(data["id"], data["card_hand"], data["first_player"])
		"played": 
			match (abs(int(data["id"] - Global.online_game_id) % 4)):
				1: 
					enemy_played(enemyhandleft, cardslotleft, data["card"], enemyhandleft.lst_card_in_slot)
				2: 
					enemy_played(enemyhandup, cardslotup, data["card"], enemyhandup.lst_card_in_slot)
				3:
					enemy_played(enemyhandright, cardslotright, data["card"], enemyhandright.lst_card_in_slot)

func enemy_played(hand, cardslot, list_card, lst_card_in_slot):
	var card_scene=preload(CARD_SCENE_PATH)

	for card in list_card:
		print(card)
		var popped_card = hand.remove_card_from_hand()  # Supprime la carte de la main
		var sprite= popped_card.get_node("Sprite")
		var card_info = Global.get_card_info_from_texture(card)
		
		popped_card.value = card_info[1]
		popped_card.form = card_info[0]
		popped_card.file = card
		popped_card.name="Card"
		popped_card.scale= card_scale
		
		sprite.texture= load(popped_card.file)
		
		var children_slots = cardslot.get_children()
		var children_slot = null
		
		for children in children_slots :
			if children.card_in_slot == false : 
				children_slot = children
				break
		
		move_card_to_slot(popped_card, children_slot, hand, lst_card_in_slot)
	
	hand.update_hand_position()

func move_card_to_slot(card, slot, hand, lst_card_in_slot):
	print(slot.position.x, slot.position.y)
	hand.animate_card_to_position(card,slot.position)
	slot.card_in_slot = true  # Marque le slot comme occupé
	slot.card_value=card.value
	slot.card_form=card.form
	lst_card_in_slot.append(card)


func _server_handshake():
	var content = JSON.stringify({
		"function": "connect",
		"profile_name": Global.username
	})
	
	socket.send_text(content)


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")
