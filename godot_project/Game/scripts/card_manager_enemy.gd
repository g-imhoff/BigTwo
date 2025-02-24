extends Node2D

const COLLISION_MASK_CARD=1
const COLLISION_MASK_SLOT=2

var screen_size
var is_hovering_on_card
var num_card_up=0
var card_clicked=[]
var compteur=0
var played=false

@onready var player_hand=$"../EnemyHand"
@onready var Cardslots=$"../Cardslots2"
@onready var children_slots=Cardslots.get_children()



func _ready() -> void:
	screen_size=get_viewport_rect().size


func on_card_played():
	await get_tree().create_timer(2.0).timeout
	if played==false:
		move_card_to_slot(player_hand.player_hand[1],children_slots[compteur])
		compteur += 1
		played = true
		player_hand.update_hand_position()  # Met à jour l'affichage de la main


func move_card_to_slot(card, slot):
	if card in player_hand.player_hand:  # Vérifie que la carte est bien dans la main du joueur
		player_hand.remove_card_from_hand(card)  # Supprime la carte de la main
		player_hand.animate_card_to_position(card,slot.position)
		slot.card_in_slot = true  # Marque le slot comme occupé
	else:
		print("Erreur : la carte n'est pas dans la main du joueur.")

func _on_card_manager_card_played() -> void:
	on_card_played()
