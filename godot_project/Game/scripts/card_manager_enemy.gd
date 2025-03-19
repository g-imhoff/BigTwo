extends Node2D

signal enemy

const COLLISION_MASK_CARD=1
const COLLISION_MASK_SLOT=2

var screen_size
var is_hovering_on_card
var num_card_up=0
var card_clicked=[]
var cmpt_card_in_slot=0
var played=false
var lst_card_in_slot=[]

@onready var hand=$"../EnemyHandUp"
@onready var Cardslots=$"../Cardslots2"
@onready var children_slots=Cardslots.get_children()



func _ready() -> void:
	screen_size=get_viewport_rect().size


func on_card_played():
	await get_tree().create_timer(2.0).timeout
	if played==false:
		var lst_card=hand.player_hand.duplicate()
		var card_to_put=[]
		lst_card.sort_custom(func(a, b): return a.value < b.value)
		if check_for_straight(lst_card)!=null:
			print("straight")
			children_slots[0].combi="straight"
			card_to_put=check_for_straight(lst_card)
		elif check_for_flush(lst_card)!=null:
			print("flush")
			children_slots[0].combi="flush"
			card_to_put=check_for_flush(lst_card)
		elif check_for_four_kind(card_to_put,lst_card)!=null:
			print("four of a kind")
			children_slots[0].combi="four of a kind"
			card_to_put=check_for_four_kind(card_to_put,lst_card)
		elif check_for_fullhouse(card_to_put,lst_card)!=null:
			print("full house")
			children_slots[0].combi="full house"
			card_to_put=check_for_fullhouse(card_to_put,lst_card)
		else:
			card_to_put=check_for_simple_combi(card_to_put,lst_card)
			if card_to_put.size()>3:
				card_to_put.erase(card_to_put[0])
			print("combi de :",card_to_put.size()," cartes")
			children_slots[0].combi=card_to_put.size()
		put_cards(card_to_put)
		played = true
		emit_signal("enemy")
		hand.update_hand_position()  # Met à jour l'affichage de la main


func move_card_to_slot(card, slot):
	if card in hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		hand.remove_card_from_hand(card)  # Supprime la carte de la main
		var sprite=card.get_node("Sprite")
		sprite.texture=card.img
		hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque le slot comme occupé
		slot.card_value=card.value
		slot.card_form=card.form
		lst_card_in_slot.append(card)
		emit_signal("enemy")
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")

	
	

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
			cmpt_card_in_slot-=1
			

func end_game():
	print("tu a gagné")
	get_tree().quit()


func _on_card_manager_enemy_left_enemy() -> void:
	played=false
	remove_card_in_slot()
	on_card_played()

func check_for_simple_combi(card_to_put,lst_card):
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
	children_slots[0].combi_value=card_to_put[0].value
	children_slots[0].combi_form=card_to_put[0].form
	return card_to_put

func check_for_straight(lst_card):
	var tmp=[]
	for i in range (lst_card.size()-1):
		if lst_card[i] not in tmp:
			tmp.append(lst_card[i])
		if (lst_card[i].value)+1 == lst_card[i+1].value:
			tmp.append(lst_card[i+1])
		else:
			tmp.clear()
		if tmp.size()==5:
			children_slots[0].combi_value=tmp[4].value
			children_slots[0].combi_form=tmp[4].form
			return tmp
	return null

func check_for_flush(lst_card):
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
			return tmp
	return null

func check_for_fullhouse(card_to_put,lst_card):
	card_to_put=check_for_simple_combi(card_to_put,lst_card)
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
						children_slots[0].combi_value=card_to_put[0].value
						children_slots[0].combi_form=card_to_put[0].form
						for card in tmp:
							card_to_put.append(card)
						return card_to_put
	return null

func check_for_four_kind(card_to_put,lst_card):
	card_to_put=check_for_simple_combi(card_to_put,lst_card)
	if card_to_put.size()==4 and hand.player_hand.size()>4:#check four of a kind
			children_slots[0].combi_value=card_to_put[0].value
			children_slots[0].combi_form=card_to_put[0].form
			for card in lst_card:
				if card not in card_to_put:
					card_to_put.append(card)
					return card_to_put
	return null

func put_cards(card_to_put):
	var card_to_remove=card_to_put.duplicate()
	for card in card_to_remove:
		if card_to_remove.size() < 5:
			move_card_to_slot(card,children_slots[cmpt_card_in_slot])
			card_to_put.erase(card)
			cmpt_card_in_slot += 1
		else:
			if cmpt_card_in_slot == 0:
				move_card_to_slot(card,children_slots[4])
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 1:
				move_card_to_slot(card,children_slots[1])
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 2:
				move_card_to_slot(card,children_slots[0])
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 3:
				move_card_to_slot(card,children_slots[2])
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
			elif cmpt_card_in_slot == 4:
				move_card_to_slot(card,children_slots[3])
				card_to_put.erase(card)
				cmpt_card_in_slot += 1
