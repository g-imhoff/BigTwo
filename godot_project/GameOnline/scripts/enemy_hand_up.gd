extends Node2D

signal send_card_right

const CARD_SCENE_PATH= "res://Game/scenes/enemy_cartes.tscn"
const HAND_COUNT=13
const CARD_WIDTH=80 #80
const HAND_Y_POSITION=120

var card_scale=Vector2(0.5,0.5)
var player_hand=[]
var lst_card_in_slot=[]
var center_screen_x

@onready var hand_left=$"../EnemyHandLeft"

func on_started() -> void:
	print("here up")
	center_screen_x=get_viewport().size.x/2
	var card_scene=preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		await hand_left.send_card_up
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		
		var new_texture=load("res://assets/cards/card_back.png") #montre juste le dos "res://assets/cards/card_back.png"
		 # Extraire la valeur et la couleur de la carte
		new_card.value = ""
		new_card.form = ""
		new_card.scale=card_scale
		sprite.texture=new_texture
		$"../card_manager".add_child(new_card)
		new_card.name="Card"
		add_card_to_hand(new_card)
		await get_tree().create_timer(0.1).timeout
		emit_signal("send_card_right")

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		update_hand_position()
	else:
		animate_card_to_position(card,card.hand_position)

func update_hand_position():
	for i in range (player_hand.size()):
		var new_position =Vector2(calculate_card_position(i),HAND_Y_POSITION)
		var card=player_hand[i]
		card.hand_position=new_position
		animate_card_to_position(card,new_position)

func calculate_card_position(index):
	var total_with=(player_hand.size()-1)*CARD_WIDTH 
	var x_offset=center_screen_x + index * CARD_WIDTH - total_with/2
	return x_offset

func animate_card_to_position(card,new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position",new_position,0.1 )

func remove_card_from_hand():
	return player_hand.pop_front()
