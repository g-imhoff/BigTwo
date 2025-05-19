extends Node2D

const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
var card_scale=Vector2(0.5,0.5)

signal verification_worked

var game_won = false
var message

@onready var endslot=$cardenslot
@onready var hand = $PlayerHand
@onready var enemyhandleft = $EnemyHandLeft
@onready var enemyhandup = $EnemyHandUp
@onready var enemyhandright = $EnemyHandRight
@onready var mycardslot = $Cardslots
@onready var cardslotleft = $Cardslots3
@onready var cardslotup = $Cardslots2
@onready var cardslotright = $Cardslots4
@onready var manager = $card_manager
@onready var playerusername = $PlayerUsername
@onready var enemyusernametop = $EnemyUsernameTop
@onready var enemyusernameleft = $EnemyUsernameLeft
@onready var enemyusernameright = $EnemyUsernameRight
@onready var playersprite = $PlayerUsername/PlayerSprite
@onready var enemytopsprite = $EnemyUsernameTop/EnemyTopSprit
@onready var enemyleftsprite = $EnemyUsernameLeft/EnemyLeftSprite
@onready var enemyrightsprite = $EnemyUsernameRight/EnemyRightSprite
@onready var endgamepopup = $EndGame
@onready var message_left=$message_left
@onready var message_right=$message_right
@onready var message_top=$message_up

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
		if not game_won : 
			get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")

func _data_received_handler(data):
	print("here")
	print(data)
	match data["function"]:
		"game_won": 
			endgamepopup.show_popup(data["winner"])
			endgamepopup.visible = true
			manager.played = true
			game_won = true 
		"connected":
			# Connected to the server game
			pass
		"played": 
			match (int((data["id"] - Global.online_game_id + 4)) % 4):
				1: 
					remove_card_in_slot(enemyhandleft, cardslotleft)
					enemy_played(enemyhandleft, cardslotleft, data["card"], enemyhandleft.lst_card_in_slot)
					enemyleftsprite.visible = false
					enemytopsprite.visible = true
				2: 
					remove_card_in_slot(enemyhandup, cardslotup)
					enemy_played(enemyhandup, cardslotup, data["card"], enemyhandup.lst_card_in_slot)
					enemytopsprite.visible = false
					enemyrightsprite.visible = true
				3:
					remove_card_in_slot(enemyhandright, cardslotright)
					enemy_played(enemyhandright, cardslotright, data["card"], enemyhandright.lst_card_in_slot)
					manager.played = false
					remove_card_in_slot(hand, mycardslot)
					enemyrightsprite.visible = false
					playersprite.visible = true
		"passed":
			match (int((data["id"] - Global.online_game_id + 4)) % 4):
				1: 
					message=message_left
					show_message("player has passed")
					remove_card_in_slot(enemyhandleft, cardslotleft)
					enemyleftsprite.visible = false
					enemytopsprite.visible = true
				2: 
					message=message_top
					show_message("player has passed")
					remove_card_in_slot(enemyhandup, cardslotup)
					enemytopsprite.visible = false
					enemyrightsprite.visible = true
				3:
					message=message_right
					show_message("player has passed")
					remove_card_in_slot(enemyhandright, cardslotright)
					manager.played = false
					remove_card_in_slot(hand, mycardslot)
					enemyrightsprite.visible = false
					playersprite.visible = true
		"verification": 
			if data["result"] == 1: 
				manager.played = true
				if (data["passed"] == 1): 
					for card in manager.card_clicked: 
						manager.move_card_up_or_down(card)
				else : 
					emit_signal("verification_worked")
				playersprite.visible = false
				enemyleftsprite.visible = true
			else: 
				Notification.show_side(data["message"])

func _on_tree_exited() -> void:
	if not game_won: 
		var content = JSON.stringify({
			"function": "leaving",
			"profile_name": Global.username,
			"room_name": SocketOnline.room_name
		})
		
		SocketOnline.socket.send_text(content)
	
		SocketOnline.socket.close()

func _ready() -> void:
	playerusername.text = Global.username
	hand._card_hand_init(SocketOnline.id, SocketOnline.card_hand, SocketOnline.first_player)
	_display_all_username(SocketOnline.list_id)

func _display_all_username(list_id: Dictionary):	
	for username in list_id:
		_display_username(username, list_id[username])

func _display_username(username, id):
	print(username)
	match (int((id - Global.online_game_id + 4)) % 4):
		0: 
			if id == 1:
				playersprite.visible = true
		1: 
			enemyusernameleft.text = username
			if id == 1:
				enemyleftsprite.visible = true
		2: 
			enemyusernametop.text = username
			if id == 1:
				enemytopsprite.visible = true
		3:
			enemyusernameright.text = username
			if id == 1:
				enemyrightsprite.visible = true

func remove_card_in_slot(hand, cardslot):
	if hand.lst_card_in_slot.size() != 0:
		# Crée une copie de la liste pour éviter la modification pendant l'itération
		var cards_to_remove = hand.lst_card_in_slot.duplicate()
		var i = 0
		
		for card in cards_to_remove:
			#card.queue_free()  # Marque la carte pour suppression
			endslot.position.x+=Global.endcardpos
			var sprite=card.get_node("Sprite")
			if sprite.rotation_degrees == 90:
				sprite.rotation_degrees-=90
			if sprite.rotation_degrees == -90:
				sprite.rotation_degrees+=90
			card.z_index=Global.index
			hand.lst_card_in_slot.erase(card)  # Retire la carte de la liste
			sprite.texture=preload("res://assets/cards/card_back.png")
			hand.animate_card_to_position(card,endslot.position)
			var children_slots = cardslot.get_children()
			children_slots[i].card_in_slot=false
			children_slots[i].card_value=null
			children_slots[i].card_form=null
			children_slots[i].combi=null
			children_slots[i].combi_value=null
			children_slots[i].combi_form=null
			i += 1
			Global.index+=1
			Global.endcardpos+=0.05

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
	hand.animate_card_to_position(card, slot.position)
	slot.card_in_slot = true  # Marque le slot comme occupé
	slot.card_value=card.value
	slot.card_form=card.form
	lst_card_in_slot.append(card)

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")

func _on_settings_btn_pressed() -> void:
	$Setting.visible = not $Setting.visible

func _on_texture_button_pressed() -> void:
	$Rules_Popup.visible = not $Rules_Popup.visible
	

func show_message(text: String, duration: float = 2.0):
	
	message.text = text
	message.visible = true
	message.add_theme_font_size_override("font_size", 24)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.4)  # R, G, B, A → noir, 50% opaque 
	style.set_content_margin_all(15)

	message.add_theme_stylebox_override("normal", style)
	hide_message_after_delay(duration)


func hide_message_after_delay(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	message.visible = false
