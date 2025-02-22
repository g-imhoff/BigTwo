extends Node2D

const COLLISION_MASK_CARD=1
const COLLISION_MASK_SLOT=2

var screen_size
var is_hovering_on_card
var player_hand_ref
var num_card_up=0
var card_clicked=[]
var compteur=0
var played=false

@onready var player_hand=$"../PlayerHand"
@onready var Cardslots=$"../Cardslots"
@onready var children_slots=Cardslots.get_children()



func _ready() -> void:
	screen_size=get_viewport_rect().size 
	player_hand_ref=$"../PlayerHand"

func _input(event):
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card=raycast_check_for_card()
			if card and played == false:
				var current_pos=card.position
				card.scale=Vector2(0.7,0.7)
				if current_pos.y==player_hand.HAND_Y_POSITION:
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
	if hovered and current_pos.y==player_hand.HAND_Y_POSITION:
		card.scale=Vector2(0.8,0.8)
		card.z_index=2
	else:
		card.scale=Vector2(0.7,0.7)
		card.z_index=1


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters=PhysicsPointQueryParameters2D.new()
	parameters.position=get_global_mouse_position()
	parameters.collide_with_areas=true
	parameters.collision_mask=COLLISION_MASK_SLOT
	var result=space_state.intersect_point(parameters)
	if result.size()>0:
		return result[0].collider.get_parent()
	return null



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


func _on_button_pressed() -> void:
	if card_clicked == []:
		print("pas de carte clicked")
	elif check_cards_clicked()==false:
		print("combinaison incorrect")
		for i in range(card_clicked.size()):
			print(card_clicked[i].value,card_clicked[i].form)
	else:
		for card in card_clicked:
			move_card_to_slot(card, children_slots[compteur])  # Déplace la carte avec la nouvelle fonction
			compteur += 1
			num_card_up -= 1
		played = true
		player_hand.update_hand_position()  # Met à jour l'affichage de la main


func move_card_to_slot(card, slot):
	if card in player_hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		player_hand.remove_card_from_hand(card)  # Supprime la carte de la main
		player_hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque le slot comme occupé
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")

func check_cards_clicked():
	var check=false
	if card_clicked.size()==1:
		check=true

	elif card_clicked.size()==2:
		if card_clicked[0].value ==  card_clicked[1].value:
			check=true
		else:
			check=false

	elif card_clicked.size()==3:
		if card_clicked[0].value == card_clicked[1].value and card_clicked[1].value == card_clicked[2].value:
			check = true
		else:
			check =false

	elif card_clicked.size()==5:
		card_clicked.sort_custom(func(a, b): return a.value < b.value)#trie les carte clique par leur valeur
		var val=0
		var signe=0
		var suite=0
		var tab_check_brelan=[]
		tab_check_brelan.append(card_clicked[0])
		for i in range(card_clicked.size()-1):
			if card_clicked[i].value== card_clicked[i+1].value:
				val+=1
				tab_check_brelan.append(card_clicked[i+1])
			if card_clicked[i].form==card_clicked[i+1].form:
				signe+=1
			if card_clicked[i+1].value== card_clicked[i].value+1:
				suite+=1
		if val == 3:#check Four of a Kind
			check=true
		elif suite==4 and signe ==4:#check pour Straight Flush
			check =true 
			print("Straight Flush")
		elif signe==4:#check Flush
			check= true
		elif suite==4:#check pour straight
			check =true
		elif val==1 or val==2:#check pour full house
			var tab_val=card_clicked.duplicate()
			for i in range(tab_check_brelan.size()):
				tab_val.erase(tab_check_brelan[i])
			if val==2:
				if tab_val[0].value ==  tab_val[1].value:
					check=true
			if val==1:
				if tab_val[0].value == tab_val[1].value and tab_val[1].value == tab_val[2].value:
					check=true
	return check
