extends Node

var websocket_url = "wss://185.155.93.105:18005"
var server_url = "wss://185.155.93.105:18006" # turn into wss://185.155.93.105:18006
var username = ""
var online_game_id = 1000 # no game

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
	elif value_str.is_valid_float():
		card_info[1] = int(value_str)
	return card_info

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

var card_duplicate = card_images.duplicate()
