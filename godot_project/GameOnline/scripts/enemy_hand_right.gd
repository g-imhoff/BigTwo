extends Node2D

const HAND_COUNT=13
const CARD_SCENE_PATH= "res://Game/scenes/enemy_cartes.tscn"
const CARD_WIDTH=60 #60
const HAND_X_POSITION=1860

var player_hand=[]
var lst_card_in_slot=[]

var card_scale=Vector2(0.5,0.5)
var center_screen_y

func on_started() -> void:
	center_screen_y=get_viewport().size.y/2
	var card_scene=preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		
		var new_texture=load("res://assets/cards/card_back.png") #montre juste le dos "res://assets/cards/card_back.png"
		 # Extraire la valeur et la couleur de la carte
		new_card.value = ""
		new_card.form = ""
		new_card.scale=card_scale
		sprite.texture=new_texture
		sprite.rotate(deg_to_rad(-90))
		$"../card_manager".add_child(new_card)
		
		new_card.name="Card"
		add_card_to_hand(new_card)

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		update_hand_position()
	else:
		animate_card_to_position(card,card.hand_position)

func update_hand_position():
	for i in range (player_hand.size()):
		var new_position =Vector2(HAND_X_POSITION,calculate_card_position(i))
		var card=player_hand[i]
		card.hand_position=new_position
		animate_card_to_position(card,new_position)

func calculate_card_position(index):
	var total_with=(player_hand.size()-1)*CARD_WIDTH 
	var y_offset=center_screen_y + index * CARD_WIDTH - total_with/2
	return y_offset

func animate_card_to_position(card,new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position",new_position,0.1 )

func remove_card_from_hand():
	return player_hand.pop_front()
