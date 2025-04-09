extends Node2D

signal card_played

const COLLISION_MASK_CARD=1

var screen_size
var is_hovering_on_card
var num_card_up=0
var card_clicked=[]
var cmpt_card_in_slot=0
var played=false
var lst_card_in_slot=[]
var card_base_scale=Vector2(0.5,0.5)
var card_highlight_scale=Vector2(0.55,0.55)
var brelan=[]

@onready var hand=$"../PlayerHand"
@onready var Cardslots=$"../Cardslots"
@onready var children_slots=Cardslots.get_children()
@onready var Cardslots_right=$"../Cardslots4"
@onready var children_slots_right=Cardslots_right.get_children()
@onready var message=$"../message"
@onready var timer =$"../Timer"


func _ready() -> void:
	screen_size=get_viewport_rect().size 

func _input(event):
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card=raycast_check_for_card()
			if card and played == false:
				move_card_up_or_down(card)


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


func _on_button_pressed() -> void:
	var three_of_diamonds = null
	for card in hand.player_hand:
		if card.value == 3 and card.form ==1:
			three_of_diamonds = card
			break
	if card_clicked == []:
		show_message("pas de carte clicked")
	elif check_other_cards()==false:
		show_message("combinaison incorrect")
	elif three_of_diamonds:
		var check=false
		for card in card_clicked:
			if card == three_of_diamonds:
				check=true
		#var cards = card_clicked.duplicate()
		#for card in cards:
			#if card and not played:  # Si une carte est cliquée et que le jeu n'a pas encore été joué
				#move_card_up_or_down(card)  # Déclenche le déplacement avec une seule ligne
		if check_other_cards()==false:
			show_message("combinaison incorrect")
		elif check!=true:
			show_message("doit jouer 3 diamonds")
		else:
			for card in card_clicked:
				if card_clicked.size() < 5:
					move_card_to_slot(card, children_slots[cmpt_card_in_slot])  # Déplace la carte avec la nouvelle fonction
					cmpt_card_in_slot += 1
					num_card_up -= 1
				else :
					if cmpt_card_in_slot == 0:
						move_card_to_slot(card,children_slots[4])
						cmpt_card_in_slot += 1
						num_card_up -=1
					elif cmpt_card_in_slot == 1:
						move_card_to_slot(card,children_slots[1])
						cmpt_card_in_slot += 1
						num_card_up -=1
					elif cmpt_card_in_slot == 2:
						move_card_to_slot(card,children_slots[0])
						cmpt_card_in_slot += 1
						num_card_up -=1
					elif cmpt_card_in_slot == 3:
						move_card_to_slot(card,children_slots[2])
						cmpt_card_in_slot += 1
						num_card_up -=1
					elif cmpt_card_in_slot == 4:
						move_card_to_slot(card,children_slots[3])
						cmpt_card_in_slot += 1
						num_card_up -=1
			played = true
			hand.update_hand_position()  # Met à jour l'affichage de la main
			if hand.player_hand.size()==0:
				end_game()
			message.visible = false
			emit_signal("card_played")
	else:
		for card in card_clicked:
			if card_clicked.size() < 5:
				move_card_to_slot(card, children_slots[cmpt_card_in_slot])  # Déplace la carte avec la nouvelle fonction
				cmpt_card_in_slot += 1
				num_card_up -= 1
			else :
				if cmpt_card_in_slot == 0:
					move_card_to_slot(card,children_slots[4])
					cmpt_card_in_slot += 1
					num_card_up -=1
				elif cmpt_card_in_slot == 1:
					move_card_to_slot(card,children_slots[1])
					cmpt_card_in_slot += 1
					num_card_up -=1
				elif cmpt_card_in_slot == 2:
					move_card_to_slot(card,children_slots[0])
					cmpt_card_in_slot += 1
					num_card_up -=1
				elif cmpt_card_in_slot == 3:
					move_card_to_slot(card,children_slots[2])
					cmpt_card_in_slot += 1
					num_card_up -=1
				elif cmpt_card_in_slot == 4:
					move_card_to_slot(card,children_slots[3])
					cmpt_card_in_slot += 1
					num_card_up -=1
		played = true
		children_slots[0].passing = 0
		hand.update_hand_position()  # Met à jour l'affichage de la main
		if hand.player_hand.size()==0:
			end_game()
		message.visible = false
		emit_signal("card_played")


func move_card_to_slot(card, slot):
	if card in hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		hand.remove_card_from_hand(card)  # Supprime la carte de la main
		hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque le slot comme occupé
		slot.card_value=card.value
		slot.card_form=card.form
		lst_card_in_slot.append(card)
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")

func check_cards_clicked():
	var check=null
	if card_clicked.size()==1:
		check="1"
		children_slots[0].combi="1"
		children_slots[0].combi_value = card_clicked[0].value
		children_slots[0].combi_form = card_clicked[0].form

	elif card_clicked.size()==2 and card_clicked[0].value ==  card_clicked[1].value:
		check="2"
		children_slots[0].combi="2"
		children_slots[0].combi_value=card_clicked[0].value
		var lst_tmp=[]
		lst_tmp=card_clicked.duplicate()
		lst_tmp.sort_custom(func(a, b): return a.form > b.form)
		children_slots[0].combi_form=card_clicked[0].form

	elif card_clicked.size()==3 and card_clicked[0].value == card_clicked[1].value and card_clicked[1].value == card_clicked[2].value:
		check="3"
		children_slots[0].combi="3"
		children_slots[0].combi_value=card_clicked[0].value
		var lst_tmp=[]
		lst_tmp=card_clicked.duplicate()
		lst_tmp.sort_custom(func(a, b): return a.form > b.form)
		children_slots[0].combi_form=card_clicked[0].form
		
	elif card_clicked.size()==5:
		card_clicked.sort_custom(func(a, b): return a.value < b.value)#trie les carte clique par leur valeur
		var val=0
		var signe=0
		var suite=0
		var tab_check_brelan=[]
		var tmp=0
		var tmp_tab=tab_check_brelan.duplicate()
		tmp_tab.append(card_clicked[0])
		for i in range(card_clicked.size()-1):
			if card_clicked[i].value== card_clicked[i+1].value:
				tmp+=1
				tmp_tab.append(card_clicked[i+1])
			elif card_clicked[i].value!= card_clicked[i+1].value or i+1==card_clicked.size()-1:
				val=tmp
				if tab_check_brelan.size()<2:
					tab_check_brelan=tmp_tab.duplicate()
				tmp=0
			if i == card_clicked.size()-2 and card_clicked[0].value!=card_clicked[card_clicked.size()-1].value and card_clicked[card_clicked.size()-1].value == card_clicked[card_clicked.size()-2].value:
				val = tmp
			if card_clicked[i].form==card_clicked[i+1].form:
				signe+=1
			if card_clicked[i+1].value== card_clicked[i].value+1:
				suite+=1
		if val == 3:#check Four of a Kind
			check="four of a kind"
			children_slots[0].combi="four of a kind"
			var val_tmp=card_clicked[0]
			if card_clicked[0]!=card_clicked[1]:
				val_tmp=card_clicked[1]
			children_slots[0].combi_value=val_tmp.value
			children_slots[0].combi_form=val_tmp.form
		elif suite==4 and signe ==4:#check pour Straight Flush
			check ="straight flush" 
			children_slots[0].combi="straight flush"
			#print("Straight Flush")
			children_slots[0].combi_value=card_clicked[4].value
			children_slots[0].combi_form=card_clicked[4].form
		elif signe==4:#check Flush
			check= "flush"
			children_slots[0].combi="flush"
			children_slots[0].combi_value=card_clicked[4].value
			children_slots[0].combi_form=card_clicked[4].form
		elif suite==4:#check pour straight
			check ="straight"
			children_slots[0].combi="straight"
			children_slots[0].combi_value=card_clicked[4].value
			children_slots[0].combi_form=card_clicked[4].form
		elif val == 1 or val == 2:  # check pour full house
			var tab_val = card_clicked.duplicate()
			for i in range(tab_check_brelan.size()):
				tab_val.erase(tab_check_brelan[i])
			if val == 2:
				brelan=tab_check_brelan.duplicate()
				if tab_val[0].value == tab_val[1].value:
					check = "full house"
					children_slots[0].combi="full house"
					children_slots[0].combi_value=brelan[0].value
					children_slots[0].combi_form=brelan[0].form
					print("full house")
			
			elif val == 1:
				brelan=tab_val.duplicate()
				if tab_val.size() == 3 and tab_val[0].value == tab_val[1].value:  # Assure que seulement 2 cartes restent
					children_slots[0].combi="full house"
					check = "full house"
					children_slots[0].combi_value=tab_val[0].value
					children_slots[0].combi_form=tab_val[0].form
					print("full house")
	return check


	


func remove_card_in_slot():
	if lst_card_in_slot.size() != 0:
		# Crée une copie de la liste pour éviter la modification pendant l'itération
		var cards_to_remove = lst_card_in_slot.duplicate()
		
		for card in cards_to_remove:
			card.queue_free()  # Marque la carte pour suppression
			lst_card_in_slot.erase(card)  # Retire la carte de la liste
			children_slots[cmpt_card_in_slot-1].card_in_slot=false
			children_slots[cmpt_card_in_slot-1].card_value=null
			children_slots[cmpt_card_in_slot-1].card_form=null
			children_slots[cmpt_card_in_slot-1].combi=null
			children_slots[cmpt_card_in_slot-1].combi_value=null
			children_slots[cmpt_card_in_slot-1].combi_form=null
			cmpt_card_in_slot-=1

func end_game():
	print("tu a gagné")
	get_tree().change_scene_to_file("res://Game/scenes/popup.tscn")


func _on_button_2_pressed() -> void:
	if played == false :
		played=true
		var card_to_remove=card_clicked.duplicate()
		for card in card_to_remove:
			card.position.y+=50
			num_card_up-=1
			card_clicked.erase(card)
		children_slots[0].combi = children_slots_right[0].combi
		children_slots[0].combi_value = children_slots_right[0].combi_value
		children_slots[0].combi_form = children_slots_right[0].combi_form
		children_slots[0].passing = 1 + children_slots_right[0].passing
		message.visible = false
		emit_signal("card_played")



func _on_card_manager_enemy_right_enemy() -> void:
	#await get_tree().create_timer(2.0).timeout
	#print(children_slots_right[0].combi_value," ",children_slots_right[0].combi_form)
	played=false
	show_message("Your turn")
	for card in card_clicked.duplicate():
		card.queue_free()
		card_clicked.erase(card)
	remove_card_in_slot() 
	if children_slots_right[0].passing == 3:
		children_slots_right[0].combi = null


#test pour faire commencé celui qui a le 3 de diamonds
func on_card_played():
	played = false
	show_message("Your turn")


func check_other_cards():
	var lst_card=card_clicked.duplicate()
	lst_card.sort_custom(func(a, b): return a.value < b.value)
	var check_combi=check_cards_clicked()

	if children_slots_right[0].combi==null and check_combi!=null:
		return true
	var combi_enemy
	combi_enemy=children_slots_right[0].combi
	if typeof(check_combi) == typeof(combi_enemy) and check_combi!=null:
		if (check_combi == "1" or check_combi == "2" or check_combi =="3"):
			if lst_card[0].value >children_slots_right[0].combi_value or (lst_card[0].value == children_slots_right[0].combi_value and lst_card[0].form > children_slots_right[0].combi_form):
				return true
			lst_card.sort_custom(func(a, b): return a.form > b.form)
			if (lst_card[0].value==children_slots_right[0].combi_value and lst_card[0].form>children_slots_right[0].combi_form ):
				return true
		elif check_combi=="four of a kind":
			var val_a_check=lst_card[0]
			if val_a_check!=lst_card[1]:
				val_a_check=lst_card[1]
			if (val_a_check.value > children_slots_right[0].combi_value) or (children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"):
				return true
		elif check_combi=="straight flush":
			if (lst_card[4].value >children_slots_right[0].combi_value and lst_card[4].form >children_slots_right[0].combi_form) or (lst_card[4].value==children_slots_right[0].combi_value and lst_card[4].form==children_slots_right[0].combi_form ) or (children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"):
				return true
		elif check_combi=="straight":
			if lst_card[4].value >children_slots_right[0].combi_value or (lst_card[4].value==children_slots_right[0].combi_value and lst_card[4].form==children_slots_right[0].combi_form ):
				return true
		elif check_combi=="flush":
			if (lst_card[4].value >children_slots_right[0].combi_value or (lst_card[4].value==children_slots_right[0].combi_value and lst_card[4].form==children_slots_right[0].combi_form )) or (children_slots_right[0].combi=="straight"):
				return true
		elif check_combi=="full house":
			if brelan[0].value>children_slots_right[0].combi_value or (children_slots_right[0].combi=="straight" or children_slots_right[0].combi=="flush"):
				return true
	children_slots[0].combi=null
	return false

func move_card_up_or_down (card):
	var current_pos=card.position
	card.scale=card_base_scale
	if current_pos.y==hand.HAND_Y_POSITION:
		if num_card_up ==5:
			show_message("to much card up")
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

#as de coeur 
func _on_sort_form_pressed() -> void:
	hand.player_hand.sort_custom(func(a, b): return a.form < b.form)
	var card_erase = card_clicked.duplicate()
	for card in card_erase:
		card_clicked.erase(card)
	hand.update_hand_position()
	num_card_up = 0

#as de trefle
func _on_sort_value_pressed() -> void:
	hand.player_hand.sort_custom(func(a, b): return a.value < b.value)
	var card_erase = card_clicked.duplicate()
	for card in card_erase:
		card_clicked.erase(card)
	hand.update_hand_position()
	num_card_up = 0

func show_message(text: String, duration: float = 3.0):
	message.text = text
	message.visible = true
	timer.start(duration)


func _on_timer_timeout() -> void:
	message.visible = false
