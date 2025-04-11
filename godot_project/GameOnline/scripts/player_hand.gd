extends Node2D

const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
var center_screen_x
var player_hand=[]
const HAND_Y_POSITION=870
const CARD_WIDTH=80
var card_scale=Vector2(0.5,0.5)
var first_player
var lst_card_in_slot=[]

@onready var enemyUp = $"../EnemyHandUp"
@onready var enemyRight = $"../EnemyHandRight"
@onready var enemyLeft = $"../EnemyHandLeft"
@onready var manager = $"../card_manager"

func _card_hand_init(id, list_card, bool_first_player):
	Global.online_game_id = id
	center_screen_x=get_viewport().size.x/2
	var card_scene=preload(CARD_SCENE_PATH)
	for card in list_card: 
		var new_card=card_scene.instantiate()
		var sprite=new_card.get_node("Sprite")
		
		var new_texture=load(card)
		var card_info = Global.get_card_info_from_texture(card)
		new_card.value = card_info[1]
		new_card.form = card_info[0]
		new_card.file = card
		new_card.name="Card"
		new_card.scale=card_scale
		sprite.texture=new_texture
		$"../card_manager".add_child(new_card)
		add_card_to_hand(new_card)
	enemyUp.on_started()
	enemyRight.on_started()
	enemyLeft.on_started()
	if bool_first_player == 1:
		first_player = true
		manager.played = false
	else : 
		first_player = false

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.append(card)
		update_hand_position()
	else:
		animate_card_to_position(card, card.hand_position)

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
	tween.tween_property(card,"position",new_position,0.1 )

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
