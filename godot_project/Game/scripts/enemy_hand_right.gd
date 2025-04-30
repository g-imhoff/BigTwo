extends Node2D

signal send_card_player

const HAND_COUNT=13
const CARD_SCENE_PATH= "res://Game/scenes/enemy_cartes.tscn"
const CARD_WIDTH=60 #60
const HAND_X_POSITION=1860

var player_hand=[]
var card_scale=Vector2(0.5,0.5)
var center_screen_y

@onready var card_l = $".."
@onready var hand_up=$"../EnemyHandUp"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_y=get_viewport().size.y/2
	var card_scene=preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		await hand_up.send_card_right
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		var selected_card=card_l.random_card()
		
		var new_texture=load("res://assets/cards/card_back.png")
		 # Extraire la valeur et la couleur de la carte
		var card_info = Global.get_card_info_from_texture(selected_card)
		new_card.value = card_info[1]
		new_card.form = card_info[0]
		new_card.img=load(selected_card)
		sprite.texture=new_texture
		
		sprite.rotate(deg_to_rad(90))
		$"../card_manager".add_child(new_card)
		new_card.scale=card_scale
		new_card.name="Card"
		
		add_card_to_hand(new_card)
		await get_tree().create_timer(0.1).timeout
		emit_signal("send_card_player")
	

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

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
