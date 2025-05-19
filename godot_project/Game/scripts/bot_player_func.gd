extends Node2D

@onready var endslot=$"../cardendslot"
@onready var hand=$"../PlayerHand"
@onready var message_left=$"../message_left"
@onready var message_right=$"../message_right"
@onready var message_top=$"../message_top"
@onready var timer=$"../Timer"

var message

func check_for_simple_combi(card_to_put,lst_card, children_slots, children_slots_right):
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
		if children_slots_right[0].combi != null and children_slots_right[0].combi.length() == 1:
			children_slots[0].combi = str(card_to_put.size())
	else :
		card_to_put = null
	return card_to_put

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
			if children_slots_right[0].combi==null or (tmp[4].value >children_slots_right[0].combi_value or (tmp[4].value==children_slots_right[0].combi_value and tmp[4].form>children_slots_right[0].combi_form ) or (children_slots[0].combi=="straight flush")):
				children_slots[0].combi_value=tmp[4].value
				children_slots[0].combi_form=tmp[4].form
				return tmp
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
			if children_slots_right[0].combi==null or (children_slots_right[0].combi=="straight") or (tmp[4].value >children_slots_right[0].combi_value or (tmp[4].value==children_slots_right[0].combi_value and tmp[4].form>children_slots_right[0].combi_form )):
				tmp.sort_custom(func(a, b): return a.value < b.value)
				children_slots[0].combi_value=tmp[4].value
				children_slots[0].combi_form=tmp[4].form
				return tmp
	return null

func check_for_fullhouse(card_to_put,lst_card, children_slots, hand, children_slots_right):
	card_to_put=check_for_simple_combi(card_to_put,lst_card, children_slots,children_slots_right)
	if hand.player_hand.size()>4 and card_to_put.size()==3:
		for i in range (lst_card.size()):
			if lst_card[i] not in card_to_put:
					var card1 = lst_card[i]
					var tmp=[]
					tmp.append(card1)
					for j in range(i + 1, lst_card.size()):
						var card2 = lst_card[j]
						if card1.value==card2.value:
							tmp.append(card2)
					if tmp.size()==2:
						if children_slots_right[0].combi==null or (children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight") or (card_to_put[0].value >children_slots_right[0].combi_value or (card_to_put[0].value==children_slots_right[0].combi_value and card_to_put[0].form>children_slots_right[0].combi_form )):
							children_slots[0].combi_value=card_to_put[0].value
							children_slots[0].combi_form=card_to_put[0].form
							for card in tmp:
								card_to_put.append(card)
							return card_to_put
	return null

func check_for_four_kind(card_to_put,lst_card, children_slots, hand, children_slots_right):
	card_to_put=check_for_simple_combi(card_to_put,lst_card, children_slots, children_slots_right)
	if card_to_put.size()==4 and hand.player_hand.size()>4:#check four of a kind
		for card in lst_card:
			if card not in card_to_put:
				if children_slots_right[0].combi==null or (card_to_put[0].value > children_slots_right[0].combi_value) or (children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"):
					card_to_put.append(card)
					children_slots[0].combi_value=card_to_put[0].value
					children_slots[0].combi_form=card_to_put[0].form
					return card_to_put
	return null

func check_for_straightflush(lst_card, children_slots,children_slots_right):
	var lst=[]
	children_slots[0].combi="straight flush"
	lst=check_for_straight(lst_card,children_slots,children_slots_right)
	if lst!=null :
		for i in range (lst.size()-1):
			if lst[i].form!=lst[i+1].form:
				return null
		if children_slots_right[0].combi!=null:
			if (lst[4].value >children_slots_right[0].combi_value ) or (lst[4].value==children_slots_right[0].combi_value and lst[4].form>children_slots_right[0].combi_form ) or (children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"):
				children_slots[0].combi_value=lst[4].value
				children_slots[0].combi_form=lst[4].form
				return lst
		else:
			children_slots[0].combi_value=lst[4].value
			children_slots[0].combi_form=lst[4].form
			return lst
	else:
		children_slots[0].combi=null
		return null

func put_cards(card_to_put, children_slots, cmpt_card_in_slot, hand, lst_card_in_slot):
	var card_to_remove=card_to_put.duplicate()
	for card in card_to_remove:
		if card_to_remove.size() < 5:
			move_card_to_slot(card_to_put[0],children_slots[cmpt_card_in_slot], hand, lst_card_in_slot)
			card_to_put.erase(card)
			cmpt_card_in_slot += 1
		else:
			if cmpt_card_in_slot == 0:
				move_card_to_slot(card,children_slots[4], hand, lst_card_in_slot)
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 1:
				move_card_to_slot(card,children_slots[1], hand, lst_card_in_slot)
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 2:
				move_card_to_slot(card,children_slots[0], hand, lst_card_in_slot)
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 3:
				move_card_to_slot(card,children_slots[2], hand, lst_card_in_slot)
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 4:
				move_card_to_slot(card,children_slots[3], hand, lst_card_in_slot)
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
				
	
func check_for_best_combi_with_card(lst_card, required_card, children_slots, hand, children_slots_right):
	var possible_combi = {
		"straight" : check_for_straight(lst_card, children_slots,children_slots_right),
		"flush":check_for_flush(lst_card, children_slots,children_slots_right),
		"four of a kind":check_for_four_kind([required_card],lst_card, children_slots, hand, children_slots_right),
		"full house":check_for_fullhouse([required_card],lst_card, children_slots, hand, children_slots_right),
		"straight flush": check_for_straightflush(lst_card, children_slots,children_slots_right)
		}
	#retourne la meilleur combinaison possible
	for name in possible_combi:
		if possible_combi[name] and required_card in possible_combi[name]:
			return {name:possible_combi[name]}
	var simple_combi = check_for_simple_combi([required_card],lst_card, children_slots, children_slots_right)
	if required_card in simple_combi:
		if simple_combi.size() == 3:
			return {"3":simple_combi}
		elif simple_combi.size() == 2:
			return {"2":simple_combi}
	children_slots[0].combi_value= required_card.value
	children_slots[0].combi_form= required_card.form
	return {"1":[required_card]}

func move_card_to_slot(card, slot, hand, lst_card_in_slot):
	if card in hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		hand.remove_card_from_hand(card)  # Supprime la carte de la main
		var sprite=card.get_node("Sprite")
		sprite.texture=card.img
		hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque le slot comme occupé
		slot.card_value=card.value
		slot.card_form=card.form
		lst_card_in_slot.append(card)
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")

func remove_card_in_slot(lst_card_in_slot, children_slots, cmpt_card_in_slot):
	if lst_card_in_slot.size() != 0:
		# Crée une copie de la liste pour éviter la modification pendant l'itération
		var cards_to_remove = lst_card_in_slot.duplicate()
		var check_cards=false
		children_slots[0].combi=null
		for card in cards_to_remove:
			endslot.position.x+=Global.endcardpos
			var sprite=card.get_node("Sprite")
			if sprite.rotation_degrees == 90:
				sprite.rotation_degrees-=90
			if sprite.rotation_degrees == -90:
				sprite.rotation_degrees+=90
			card.z_index=Global.index
			lst_card_in_slot.erase(card)  # Retire la carte de la liste
			sprite.texture=preload("res://assets/cards/card_back.png")
			hand.animate_card_to_position(card,endslot.position)
			children_slots[cmpt_card_in_slot-1].card_in_slot=false
			children_slots[cmpt_card_in_slot-1].card_value=null
			children_slots[cmpt_card_in_slot-1].card_form=null
			children_slots[cmpt_card_in_slot-1].combi_value=null
			children_slots[cmpt_card_in_slot-1].combi_form=null
			cmpt_card_in_slot-=1
			check_cards=true
		if check_cards==true:
			Global.index+=1
			Global.endcardpos+=0.02

func on_card_played(children_slots_right, children_slots, played, hand, cmpt_card_in_slot, lst_card_in_slot,player):
	if played==false:
		var lst_card=hand.player_hand.duplicate()
		var card_to_put=[]
		var three_of_diamonds = null
		var can_play = false
		lst_card.sort_custom(func(a, b): return a.value < b.value)
		for card in lst_card:
			if card.value == 3 and card.form == 1:
				three_of_diamonds = card
				break
		if children_slots_right[0].passing == 3:
			children_slots_right[0].combi = null
		if three_of_diamonds:
			card_to_put.append(three_of_diamonds)
			var combi_dict = check_for_best_combi_with_card(lst_card, three_of_diamonds, children_slots, hand, children_slots_right)
			if combi_dict:
				var combi_name = combi_dict.keys()[0]
				children_slots[0].combi = combi_name
				card_to_put = combi_dict[combi_name]
				can_play = true
		elif ((check_for_straightflush(lst_card, children_slots,children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_straightflush(lst_card, children_slots,children_slots_right)!=null and (children_slots_right[0].combi=="straight flush" or children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight"))):
				children_slots[0].combi="straight flush"
				card_to_put=check_for_straightflush(lst_card, children_slots,children_slots_right)
				can_play=true
		elif (check_for_straight(lst_card, children_slots,children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_straight(lst_card, children_slots,children_slots_right)!=null and children_slots_right[0].combi=="straight"):
			#print("straight")
				children_slots[0].combi="straight"
				card_to_put=check_for_straight(lst_card, children_slots,children_slots_right)
				can_play = true
		elif (check_for_flush(lst_card, children_slots,children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_flush(lst_card, children_slots,children_slots_right)!=null and (children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight") ) :
			#print("flush")
			children_slots[0].combi="flush"
			card_to_put=check_for_flush(lst_card, children_slots,children_slots_right)
			can_play = true
		elif (check_for_four_kind(card_to_put,lst_card, children_slots, hand, children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_four_kind(card_to_put,lst_card, children_slots, hand, children_slots_right)!=null and (children_slots_right[0].combi=="four of a kind" or children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight")) :
			#print("four of a kind")
			children_slots[0].combi="four of a kind"
			card_to_put=check_for_four_kind(card_to_put,lst_card, children_slots, hand, children_slots_right)
			can_play = true
		elif (check_for_fullhouse(card_to_put,lst_card, children_slots, hand, children_slots_right)!=null and children_slots_right[0].combi==null) or (check_for_fullhouse(card_to_put,lst_card, children_slots, hand, children_slots_right)!=null and (children_slots_right[0].combi=="full house" or children_slots_right[0].combi=="flush" or children_slots_right[0].combi=="straight")) :
			#print("full house")
			children_slots[0].combi="full house"
			card_to_put=check_for_fullhouse(card_to_put,lst_card, children_slots, hand, children_slots_right)
			can_play = true
		else:
			if children_slots_right[0].combi==null:
				card_to_put=check_for_simple_combi(card_to_put,lst_card, children_slots, children_slots_right)
				if card_to_put.size()>3:
					card_to_put.erase(card_to_put[0])
				#print("combi de :",card_to_put.size()," cartes")
				children_slots[0].combi=str(card_to_put.size())
				if card_to_put != null:
					can_play = true
			else:
				card_to_put=check_for_simple_combi(card_to_put,lst_card, children_slots, children_slots_right)
				var check_size = children_slots_right[0].combi
				if check_size.length() == 1:
					while(lst_card.size()!=0):
						if card_to_put.size()>3:
							card_to_put.erase(card_to_put[0])
						if card_to_put.size()==int(check_size) :
							if card_to_put[0].value>children_slots_right[0].combi_value or (card_to_put[0].value == children_slots_right[0].combi_value and card_to_put[0].form > children_slots_right[0].combi_form):
								break
						for card in card_to_put:
							lst_card.erase(card)
						card_to_put=[]
						card_to_put=check_for_simple_combi(card_to_put,lst_card, children_slots, children_slots_right)
					if lst_card.size()!=0:
						can_play = true
		if can_play:
			put_cards(card_to_put, children_slots, cmpt_card_in_slot, hand, lst_card_in_slot)
			children_slots[0].passing = 0
			hand.update_hand_position()  # Met à jour l'affichage de la main
			if hand.player_hand.size() == 0:
				end_game()
		else :
			if (player=="left"):
				message=message_left
			elif(player=="right"):
				message=message_right
			else:
				message=message_top
			show_message("player has passed")
			children_slots[0].combi = children_slots_right[0].combi
			children_slots[0].combi_value = children_slots_right[0].combi_value
			children_slots[0].combi_form = children_slots_right[0].combi_form
			children_slots[0].passing = 1 + children_slots_right[0].passing
		played = true

func end_game():
	print("tu a gagné")
	Global.index-=Global.index-1
	Global.endcardpos-=Global.endcardpos
	print("finale",Global.index,"/",Global.endcardpos)
	$"../EndGame".set_visible(true)
	$"../EndGame/PlayerWinner".text = "You lost"
	$"../EndGame".process_mode = Node.PROCESS_MODE_ALWAYS



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
	
