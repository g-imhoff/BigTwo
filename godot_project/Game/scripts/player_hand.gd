extends Node2D


signal send_card_left
signal finished_distribution

const HAND_COUNT=13
const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
const CARD_WIDTH=80
const HAND_Y_POSITION=910

var player_hand=[]
var center_screen_x
var card_scale=Vector2(0.5,0.5)

@onready var card_l = $".."
@onready var hand_right=$"../EnemyHandRight"

#var lst_img=[
	#"res://assets/cards/card_diamonds_03.png",
	#"res://assets/cards/card_clubs_04.png",
	#"res://assets/cards/card_diamonds_05.png",
	#"res://assets/cards/card_diamonds_10.png",
	#"res://assets/cards/card_diamonds_06.png",
	#"res://assets/cards/card_diamonds_07.png",
	#]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x=get_viewport().size.x/2
	var card_scene=preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		await hand_right.send_card_player
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		var selected_card=card_l.random_card()
			
		var new_texture=load(selected_card)
		# Extraire la valeur et la couleur de la carte
		var card_info = Global.get_card_info_from_texture(selected_card)
		new_card.value = card_info[1]
		new_card.form = card_info[0]
		sprite.texture=new_texture
		$"../card_manager".add_child(new_card)
		new_card.scale=card_scale
		new_card.name="Card"
		add_card_to_hand(new_card)
		await get_tree().create_timer(0.1).timeout
		emit_signal("send_card_left")
	emit_signal("finished_distribution")




	
	
	
func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		update_hand_position()
		animate_card_to_position(card,card.hand_position)
	else:
		animate_card_to_position(card,card.hand_position)

func update_hand_position():
	for i in range (player_hand.size()):
		var new_position =Vector2(calculate_card_position(i),HAND_Y_POSITION)
		var card=player_hand[i]
		card.hand_position=new_position
		card.z_index = i + 1
		card.remove_meta("z_index")
		animate_card_to_position(card,new_position)


func calculate_card_position(index):
	var total_with=(player_hand.size()-1)*CARD_WIDTH 
	var x_offset=center_screen_x + index * CARD_WIDTH - total_with/2
	return x_offset
	
	
func animate_card_to_position(card,new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card,"position",new_position,0.15)
	

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
