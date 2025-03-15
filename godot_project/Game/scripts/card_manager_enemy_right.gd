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

@onready var hand=$"../EnemyHandRight"
@onready var Cardslots=$"../Cardslots4"
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
			card_to_put=check_for_straight(lst_card)
		elif check_for_flush(lst_card)!=null:
			print("flush")
			card_to_put=check_for_flush(lst_card)
		else:
			card_to_put=check_for_simple_combi(card_to_put,lst_card)
		var card_to_remove=card_to_put.duplicate()
		if card_to_put.size()==4 and hand.player_hand.size()<5:#check four of a kind
			card_to_put.erase(card_to_put[0])
			card_to_remove.erase(card_to_remove[0])
			for card in card_to_remove:
				if cmpt_card_in_slot < children_slots.size():
					move_card_to_slot(card_to_put[0],children_slots[cmpt_card_in_slot])
					card_to_put.erase(card)
					cmpt_card_in_slot += 1
		elif card_to_put.size()==4:
			for card in card_to_remove:
				if cmpt_card_in_slot < children_slots.size():
					move_card_to_slot(card_to_put[0],children_slots[cmpt_card_in_slot])
					card_to_put.erase(card)
					cmpt_card_in_slot += 1
			move_card_to_slot(hand.player_hand[0],children_slots[cmpt_card_in_slot])
		else:
			if hand.player_hand.size()>4 and check_for_fullhouse(card_to_put,lst_card)!=null and card_to_put.size()==3:
				var tmp=check_for_fullhouse(card_to_put,lst_card)
				for card in tmp:
					card_to_remove.append(card)
					card_to_put.append(card)
				for card in card_to_remove:
					if cmpt_card_in_slot < children_slots.size():
						move_card_to_slot(card_to_put[0],children_slots[cmpt_card_in_slot])
						card_to_put.erase(card)
						cmpt_card_in_slot += 1
			else:
				for card in card_to_remove:
					if cmpt_card_in_slot < children_slots.size():
						move_card_to_slot(card_to_put[0],children_slots[cmpt_card_in_slot])
						card_to_put.erase(card)
						cmpt_card_in_slot += 1
		played = true
		
		hand.update_hand_position()  # Met à jour l'affichage de la main


func move_card_to_slot(card, slot):
	if card in hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		hand.remove_card_from_hand(card)  # Supprime la carte de la main
		var sprite=card.get_node("Sprite")
		sprite.texture=card.img
		hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque le slot comme occupé
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
			cmpt_card_in_slot-=1
			

func end_game():
	print("tu a gagné")
	get_tree().quit()


func _on_card_manager_enemy_enemy() -> void:
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
	return card_to_put

func check_for_straight(lst_card):
	var tmp=[]
	for i in range (lst_card.size()-1):
		if lst_card[i] not in tmp:
			tmp.append(lst_card[i])
		if (lst_card[i].value)+1 == lst_card[i+1].value:
			tmp.append(lst_card[i+1])
		else:
			var tmp2=tmp.duplicate()
			for card in tmp2:
				tmp.erase(card)
		if tmp.size()==5:
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
			return tmp
	return null

func check_for_fullhouse(card_to_put,lst_card):
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
					return tmp
	return null
