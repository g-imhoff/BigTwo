extends Node

var websocket_url = "wss://185.155.93.105:18005"
var server_url = "wss://185.155.93.105:18006" # turn into wss://185.155.93.105:18006
var username = ""

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
