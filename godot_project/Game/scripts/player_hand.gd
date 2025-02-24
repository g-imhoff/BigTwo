extends Node2D

const HAND_COUNT=13
const CARD_SCENE_PATH= "res://Game/scenes/cartes.tscn"
const CARD_WIDTH=120
const HAND_Y_POSITION=870

var player_hand=[]
var center_screen_x

var card_images=[
	"res://assets/cards/card_clubs_02.png",
	"res://assets/cards/card_clubs_03.png",
	"res://assets/cards/card_clubs_04.png",
	"res://assets/cards/card_clubs_05.png",
	"res://assets/cards/card_clubs_06.png",
	"res://assets/cards/card_clubs_07.png",
	"res://assets/cards/card_clubs_08.png",
	"res://assets/cards/card_clubs_09.png",
	"res://assets/cards/card_clubs_10.png",
	"res://assets/cards/card_clubs_A.png",
	"res://assets/cards/card_clubs_J.png",
	"res://assets/cards/card_clubs_K.png",
	"res://assets/cards/card_clubs_Q.png",
	"res://assets/cards/card_diamonds_02.png",
	"res://assets/cards/card_diamonds_03.png",
	"res://assets/cards/card_diamonds_04.png",
	"res://assets/cards/card_diamonds_05.png",
	"res://assets/cards/card_diamonds_06.png",
	"res://assets/cards/card_diamonds_07.png",
	"res://assets/cards/card_diamonds_08.png",
	"res://assets/cards/card_diamonds_09.png",
	"res://assets/cards/card_diamonds_10.png",
	"res://assets/cards/card_diamonds_A.png",
	"res://assets/cards/card_diamonds_J.png",
	"res://assets/cards/card_diamonds_K.png",
	"res://assets/cards/card_diamonds_Q.png",
	"res://assets/cards/card_hearts_02.png",
	"res://assets/cards/card_hearts_03.png",
	"res://assets/cards/card_hearts_04.png",
	"res://assets/cards/card_hearts_05.png",
	"res://assets/cards/card_hearts_06.png",
	"res://assets/cards/card_hearts_07.png",
	"res://assets/cards/card_hearts_08.png",
	"res://assets/cards/card_hearts_09.png",
	"res://assets/cards/card_hearts_10.png",
	"res://assets/cards/card_hearts_A.png",
	"res://assets/cards/card_hearts_J.png",
	"res://assets/cards/card_hearts_K.png",
	"res://assets/cards/card_hearts_Q.png",
	"res://assets/cards/card_spades_02.png",
	"res://assets/cards/card_spades_03.png",
	"res://assets/cards/card_spades_04.png",
	"res://assets/cards/card_spades_05.png",
	"res://assets/cards/card_spades_06.png",
	"res://assets/cards/card_spades_07.png",
	"res://assets/cards/card_spades_08.png",
	"res://assets/cards/card_spades_09.png",
	"res://assets/cards/card_spades_10.png",
	"res://assets/cards/card_spades_A.png",
	"res://assets/cards/card_spades_J.png",
	"res://assets/cards/card_spades_K.png",
	"res://assets/cards/card_spades_Q.png",
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
		var card_info =get_card_info_from_texture(selected_card)
		new_card.value = card_info[1]
		new_card.form = card_info[0]
		sprite.texture=new_texture
		$"../card_manager".add_child(new_card)
		new_card.name="Card"
		add_card_to_hand(new_card)

func get_card_info_from_texture(path:String)->Array:
	var card_info=[null, null]
	
	if path.find("clubs")!=-1:
		card_info[0]="clubs"
	elif path.find("diamonds")!=-1:
		card_info[0]="diamonds"
	elif path.find("hearts")!=-1:
		card_info[0]="hearts"
	elif path.find("spades")!=-1:
		card_info[0]="spades"
	
	var value_str=path.split("_")[2].split(".")[0]
	
	if value_str=="A":
		card_info[1]=14
	elif value_str=="K":
		card_info[1]=13
	elif value_str=="Q":
		card_info[1]=12
	elif value_str=="J":
		card_info[1]=11
	elif value_str.is_valid_float():
		card_info[1] = int(value_str)
	return card_info

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0,card)
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
	if card_images.size()>0:
		var pos_carte_random=randi()%card_images.size()
		var selected_card=card_images[pos_carte_random]
		card_images.remove_at(pos_carte_random)
		return selected_card
	else:
		return null
