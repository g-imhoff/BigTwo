extends Node2D

signal card_enemy_played

const COLLISION_MASK_CARD=1
const COLLISION_MASK_SLOT=2

var screen_size
var is_hovering_on_card
var num_card_up=0
var card_clicked=[]
var lst_card_in_slot=[]
var compteur=0
var played=false

@onready var hand=$"../EnemyHand"
@onready var Cardslots=$"../Cardslots2"
@onready var children_slots=Cardslots.get_children()



func _ready() -> void:
	screen_size=get_viewport_rect().size


func on_card_played():
	await get_tree().create_timer(2.0).timeout
	if played==false:
		move_card_to_slot(hand.player_hand[1],children_slots[compteur])
		compteur += 1
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
		emit_signal("card_enemy_played")
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")

func _on_card_manager_card_played() -> void:
	played = false
	clear_slot()
	on_card_played()
	
func clear_slot():
	if lst_card_in_slot.size()!=0:
		#Crée une copie de la liste pour éviter les modification pendant l'itération
		var cards_to_remove = lst_card_in_slot.duplicate()
		
		for card in cards_to_remove:
			card.queue_free()
			lst_card_in_slot.erase(card)
			children_slots[compteur-1].card_in_slot = false
			compteur-=1
			
func end_game():
	print("tu as gagné")
	get_tree().quit()
