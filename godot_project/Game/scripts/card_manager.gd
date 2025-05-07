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
var straightForFlush=[]

@onready var hand=$"../PlayerHand"
@onready var Cardslots=$"../Cardslots"
@onready var children_slots=Cardslots.get_children()
@onready var Cardslots_right=$"../Cardslots4"
@onready var children_slots_right=Cardslots_right.get_children()
@onready var message=$"../message"
@onready var timer =$"../Timer"
@onready var endslot=$"../cardendslot"


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
	if card_clicked.size()==1 or card_clicked.size()==2 or card_clicked.size()==3:
		check = check_for_simple_combi(card_clicked,children_slots,children_slots_right)[1]
		
	elif card_clicked.size()==5:
		card_clicked.sort_custom(func(a, b): return a.value < b.value)#trie les carte clique par leur valeur
		if ((check_for_straightflush(card_clicked, children_slots,children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_straightflush(card_clicked, children_slots,children_slots_right)!=null and (children_slots_right[0].combi=="straight flush" or children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"))):
				check =check_for_straightflush(card_clicked, children_slots,children_slots_right)
				children_slots[0].combi="straight flush"
		elif (check_for_straight(card_clicked, children_slots,children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_straight(card_clicked, children_slots,children_slots_right)!=null and children_slots_right[0].combi=="straight"):
			#print("straight")
				check =check_for_straight(card_clicked, children_slots,children_slots_right)
				children_slots[0].combi="straight"
		elif (check_for_flush(card_clicked, children_slots,children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_flush(card_clicked, children_slots,children_slots_right)!=null and (children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight") ) :
			#print("flush")
			check=check_for_flush(card_clicked, children_slots,children_slots_right)
			children_slots[0].combi="flush"
		elif (check_for_four_kind(card_clicked, children_slots, hand, children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_four_kind(card_clicked, children_slots, hand, children_slots_right)!=null and (children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight")) :
			#print("four of a kind")
			check=check_for_four_kind(card_clicked, children_slots, hand, children_slots_right)
			children_slots[0].combi="four of a kind"
		elif (check_for_fullhouse(card_clicked, children_slots, hand, children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_fullhouse(card_clicked, children_slots, hand, children_slots_right)!=null and (children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight")) :
			#print("full house")
			check=check_for_fullhouse(card_clicked, children_slots, hand, children_slots_right)
			children_slots[0].combi="full house"
	return check


	


func remove_card_in_slot():
	if lst_card_in_slot.size() != 0:
		# Crée une copie de la liste pour éviter la modification pendant l'itération
		var cards_to_remove = lst_card_in_slot.duplicate()
		var check_cards=false
		for card in cards_to_remove:
			lst_card_in_slot.erase(card)  # Retire la carte de la liste
			endslot.position.x+=Global.endcardpos
			var sprite=card.get_node("Sprite")
			sprite.texture=preload("res://assets/cards/card_back.png")
			card.z_index = Global.index
			hand.animate_card_to_position(card,endslot.position)
			children_slots[cmpt_card_in_slot-1].card_in_slot=false
			children_slots[cmpt_card_in_slot-1].card_value=null
			children_slots[cmpt_card_in_slot-1].card_form=null
			children_slots[cmpt_card_in_slot-1].combi=null
			children_slots[cmpt_card_in_slot-1].combi_value=null
			children_slots[cmpt_card_in_slot-1].combi_form=null
			cmpt_card_in_slot-=1
			check_cards=true
		if check_cards==true:
			Global.index+=1
			Global.endcardpos+=0.1



func end_game():
	print("tu a gagné")
	$"../EndGame".set_visible(true)
	$"../EndGame/PlayerWinner".text = "You win"
	$"../EndGame".process_mode = Node.PROCESS_MODE_ALWAYS


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
		#card.queue_free()
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

func show_message(text: String, duration: float = 2.0):
	message.text = text
	message.visible = true
	message.add_theme_font_size_override("font_size", 24)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.4)  # R, G, B, A → noir, 50% opaque 
	style.set_content_margin_all(15)

	message.add_theme_stylebox_override("normal", style)
	timer.start(duration)


func _on_timer_timeout() -> void:
	message.visible = false

func check_for_simple_combi(lst_card, children_slots, children_slots_right):
	var card_to_put = []
	for i in range (lst_card.size()):
			var card1 = lst_card[i]
			var tmp=[]
			tmp.append(card1)
			for j in range(i + 1, lst_card.size()):
				var card2 = lst_card[j]
				if card1.value==card2.value:
					tmp.append(card2)
			if tmp.size()>card_to_put.size():
				card_to_put=tmp
	if card_to_put!= null and card_to_put.size() > 0:
		children_slots[0].combi_value=card_to_put[0].value
		children_slots[0].combi_form=card_to_put[0].form
		children_slots[0].combi = str(card_to_put.size())
	else :
		card_to_put = null
	if card_to_put.size()==3:
		brelan=card_to_put.duplicate()
	return [card_to_put.size(), children_slots[0].combi, card_to_put]

func check_for_straight(lst_card, children_slots,children_slots_right):
	var tmp=[]
	var lst_card_dupli=[]
	lst_card_dupli=lst_card.duplicate()
	lst_card_dupli.sort_custom(func(a, b): return a.value < b.value)
	for i in range (lst_card_dupli.size()-1):
		if lst_card_dupli[i] not in tmp:
			tmp.append(lst_card[i])
		if (lst_card_dupli[i].value)+1 == lst_card_dupli[i+1].value:
			tmp.append(lst_card_dupli[i+1])
		else:
			tmp.clear()
		if tmp.size()==5: 
			children_slots[0].combi_value=tmp[4].value
			children_slots[0].combi_form=tmp[4].form
			straightForFlush=tmp.duplicate()
			return "straight"
	return null

func check_for_flush(lst_card, children_slots,children_slots_right):
	lst_card.sort_custom(func(a, b): return a.form < b.form)
	var tmp=[]
	for i in range (lst_card.size()-1):
		if lst_card[i] not in tmp:
			tmp.append(lst_card[i])
		if lst_card[i].form == lst_card[i+1].form:
			tmp.append(lst_card[i+1])
		else:
			var tmp2=tmp.duplicate()
			for card in tmp2:
				tmp.erase(card)
		if tmp.size()==5: 
			tmp.sort_custom(func(a, b): return a.value < b.value)
			children_slots[0].combi_value=tmp[4].value
			children_slots[0].combi_form=tmp[4].form
			return "flush"
	return null

func check_for_fullhouse(lst_card, children_slots, hand, children_slots_right):
	var card_to_put=[]
	card_to_put = check_for_simple_combi(lst_card, children_slots,children_slots_right)
	if hand.player_hand.size()>4 and card_to_put[0]==3:
		for i in range (lst_card.size()):
			if lst_card[i] not in card_to_put[2]:
					var card1 = lst_card[i]
					var tmp=[]
					tmp.append(card1)
					for j in range(i + 1, lst_card.size()):
						var card2 = lst_card[j]
						if card1.value==card2.value:
							tmp.append(card2)
					if tmp.size()==2:
						children_slots[0].combi_value=card_to_put[2][0].value
						children_slots[0].combi_form=card_to_put[2][0].form
						return "full house"
	return null

func check_for_four_kind(lst_card, children_slots, hand, children_slots_right):
	var card_to_put=[0]
	card_to_put = check_for_simple_combi(lst_card, children_slots, children_slots_right)
	if card_to_put[0]==4 and hand.player_hand.size()>4:#check four of a kind
		for card in lst_card:
			if card not in card_to_put[2]:
					children_slots[0].combi_value=card_to_put[2][0].value
					children_slots[0].combi_form=card_to_put[2][0].form
					return "four of a kind"
	return null

func check_for_straightflush(lst_card, children_slots,children_slots_right):
	var lst=[]
	children_slots[0].combi="straight flush"
	lst=check_for_straight(lst_card,children_slots,children_slots_right)
	if lst!=null :
		for i in range (straightForFlush.size()-1):
			if straightForFlush[i].form!=straightForFlush[i+1].form:
				return null
		if children_slots_right[0].combi!=null:
			if (straightForFlush[4].value >children_slots_right[0].combi_value ) or (straightForFlush[4].value==children_slots_right[0].combi_value and straightForFlush[4].form>children_slots_right[0].combi_form ) or (children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"):
				children_slots[0].combi_value=straightForFlush[4].value
				children_slots[0].combi_form=straightForFlush[4].form
				return children_slots[0].combi
		else:
			children_slots[0].combi_value=straightForFlush[4].value
			children_slots[0].combi_form=straightForFlush[4].form
			return children_slots[0].combi
	else:
		children_slots[0].combi=null
		return null
