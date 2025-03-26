extends Node2D

const HAND_COUNT=6
const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
const CARD_WIDTH=80
const HAND_Y_POSITION=870

var player_hand=[]
var center_screen_x
var card_scale=Vector2(0.5,0.5)

#@onready var lst_img=Global.card_images


var lst_img=[
	"res://assets/cards/card_diamonds_05.png",
	"res://assets/cards/card_hearts_05.png",
	"res://assets/cards/card_spades_05.png",
	"res://assets/cards/card_diamonds_10.png",
	"res://assets/cards/card_clubs_05.png",
	"res://assets/cards/card_clubs_06.png",
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x=get_viewport().size.x/2
	var card_scene=preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		var selected_card=random_card()
		
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
	

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)

func random_card():
	if lst_img.size()>0:
		var pos_carte_random=randi()%lst_img.size()
		var selected_card=lst_img[pos_carte_random]
		lst_img.remove_at(pos_carte_random)
		return selected_card
	else:
		return null
