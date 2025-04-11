extends Node2D

var is_hovering_on_card
var card_highlight_scale=Vector2(0.55,0.55)
var card_base_scale=Vector2(0.5,0.5)
var played=true
var num_card_up=0
var card_clicked=[]
var first_play=true

const COLLISION_MASK_CARD=1

@onready var hand=$"../PlayerHand"
@onready var connect = $".."
@onready var cardslot = $"../Cardslots"
@onready var playersprite = $"../PlayerUsername/PlayerSprite"
@onready var enemyleftsprite = $"../EnemyUsernameLeft/EnemyLeftSprite"

func _input(event):
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card=raycast_check_for_card()
			if card and played == false:
				move_card_up_or_down(card)

func move_card_up_or_down (card):
	var current_pos=card.position
	card.scale=card_base_scale
	if current_pos.y==hand.HAND_Y_POSITION:
		if num_card_up ==5:
			print("to much card up")
		else:
			num_card_up +=1
			current_pos.y=current_pos.y-50
			card.position=current_pos
			card_clicked.append(card)
	else:
		num_card_up-=1
		current_pos.y=current_pos.y+50
		card.position=current_pos
		card_clicked.erase(card)

func connect_card_signals(card):
	card.connect("hovered",on_hovered_over_card)
	card.connect("hovered_off",on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card=true
		highlight_card(card,true)

func on_hovered_off_card(card):
	highlight_card(card,false)
	var new_card_hovered=raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered,true)
	else:
		is_hovering_on_card=false

func highlight_card(card,hovered):
	var current_pos=card.position
	if !card.has_meta("z_index"):
		card.set_meta("z_index", card.z_index)
	if hovered and current_pos.y==hand.HAND_Y_POSITION:
		card.scale=card_highlight_scale
		card.z_index = card.get_meta("z_index") + 2
	else:
		card.scale=card_base_scale
		card.z_index = card.get_meta("z_index")
		
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters=PhysicsPointQueryParameters2D.new()
	parameters.position=get_global_mouse_position()
	parameters.collide_with_areas=true
	parameters.collision_mask=COLLISION_MASK_CARD
	var result=space_state.intersect_point(parameters)
	if result.size()>0:
		return get_card_with_hightest_z_index(result)
	return null

func get_card_with_hightest_z_index(card):
	# On suppose que le premier objet de la liste est celui avec le plus grand z_index initialement
	var hightest_z_card=card[0].collider.get_parent()
	var hightest_z_index=hightest_z_card.z_index
	
	# On parcourt les autres objets détectés
	for i in range(1,card.size()):
		var current_card=card[i].collider.get_parent()
		# Si le z_index de la carte courante est plus élevé que le précédent, on la sélectionne
		if current_card.z_index > hightest_z_index:
			hightest_z_card=current_card
			hightest_z_index=current_card.z_index
		
	# On renvoie la carte avec le plus grand z_index, celle qui est visuellement au-dessus des autres
	return hightest_z_card


func _on_play_pressed() -> void:
	if first_play && hand.first_player: 
		var valid = false
		for card in hand.player_hand:
			if card.value == 3 and card.form == 1:
				valid = true
				first_play = false
				hand.first_player = false
				break
		if valid == false: 
			Notification.show_side("You need to play the three of diamond")
			return 
			
	if card_clicked == []:
		print("pas de carte clicked")
	else:
		var card_played = []
		
		for card in card_clicked: 
			card_played.append(card.file)
		
		var content = JSON.stringify({
			"id": Global.online_game_id,
			"function": "play",
			"profile_name": Global.username,
			"card": card_played
		})
		
		connect.socket.send_text(content)
	 
func move_card_to_slot(card, slot):
	if card in hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		hand.remove_card_from_hand(card)  # Supprime la carte de la main
		hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque e slot comme occupé
		slot.card_value=card.value
		slot.card_form=card.form
		hand.lst_card_in_slot.append(card)
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")


func _on_connect_server_verification_worked() -> void:
	for card in card_clicked:
		
		var children_slots = cardslot.get_children()
		var children_slot = null
		
		for children in children_slots :
			if children.card_in_slot == false : 
				children_slot = children
				break
		
		move_card_to_slot(card, children_slot)
	
	card_clicked.clear()
	hand.update_hand_position()


func _on_button_2_pressed() -> void:
	if not played : 
		if first_play && hand.first_player: 
			Notification.show_side("You need to play the first move")
		else : 
			var content = JSON.stringify({
				"id": Global.online_game_id,
				"function": "pass",
			})
			
			connect.socket.send_text(content)
			playersprite.visible = false
			enemyleftsprite.visible = true


func _on_sort_form_pressed() -> void:
	hand.player_hand.sort_custom(func(a, b): return a.form < b.form)
	var card_erase = card_clicked.duplicate()
	for card in card_erase:
		card_clicked.erase(card)
	hand.update_hand_position()
	num_card_up = 0


func _on_sort_value_pressed() -> void:
	hand.player_hand.sort_custom(func(a, b): return a.value < b.value)
	var card_erase = card_clicked.duplicate()
	for card in card_erase:
		card_clicked.erase(card)
	hand.update_hand_position()
	num_card_up = 0
