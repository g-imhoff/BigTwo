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
		var num_cards_played = min(2,hand.player_hand.size())
		for i in range(num_cards_played):
			if cmpt_card_in_slot < children_slots.size():
				move_card_to_slot(hand.player_hand[1],children_slots[cmpt_card_in_slot])
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
