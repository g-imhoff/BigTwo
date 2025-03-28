extends Node2D

const HAND_COUNT=13
const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
const CARD_WIDTH=80
const HAND_Y_POSITION=870

var player_hand=[]
var center_screen_x
var card_scale=Vector2(0.5,0.5)

@onready var lst_img=Global.card_images





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
		var card_info =get_card_info_from_texture(selected_card)
		new_card.value = card_info[1]
		new_card.form = card_info[0]
		sprite.texture=new_texture
		$"../card_manager".add_child(new_card)
		new_card.scale=card_scale
		new_card.name="Card"
		add_card_to_hand(new_card)

func get_card_info_from_texture(path:String)->Array:
	var card_info=[null, null]
	
	if path.find("clubs")!=-1:
		card_info[0]=2
	elif path.find("diamonds")!=-1:
		card_info[0]=1
	elif path.find("hearts")!=-1:
		card_info[0]=3
	elif path.find("spades")!=-1:
		card_info[0]=4
	
	var value_str=path.split("_")[2].split(".")[0]
	
	if value_str=="A":
		card_info[1]=14
	elif value_str=="K":
		card_info[1]=13
	elif value_str=="Q":
		card_info[1]=12
	elif value_str=="J":
		card_info[1]=11
	elif value_str=="02":
		card_info[1]=15
	elif value_str.is_valid_float():
		card_info[1] = int(value_str)
	return card_info

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

func random_card():
	if lst_img.size()>0:
		var pos_carte_random=randi()%lst_img.size()
		var selected_card=lst_img[pos_carte_random]
		lst_img.remove_at(pos_carte_random)
		return selected_card
	else:
		return null
