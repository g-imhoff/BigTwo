extends Node

var api_url = "http://185.155.93.105:18005" 
var server_url = "ws://185.155.93.105:18006" # turn into wss://185.155.93.105:18006

# User information
var username: String = ""
var avatar: int = -1
var game_won: int = 0
var game_played: int = 0
var connection_token: String = ""
var email = ""

var online_game_id = 1000 # no game
var index=1
var endcardpos=0
var remaining_data: SaveData = SaveData.load_or_create()

func _ready() -> void:
	print("a")
	if Global.remaining_data.username != "":
		check_connectivity()
	
	# Setup timer for checking connectivity every 30 seconds
	var timer = Timer.new()
	timer.wait_time = 30.0  # 30 seconds
	timer.autostart = true
	timer.timeout.connect(periodic_connectivity_check)
	add_child(timer)

func check_connectivity():
	await get_tree().process_frame
	
	var http_request = HTTPRequest.new()
	get_tree().root.add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	print(Global.remaining_data.username, Global.remaining_data.connection_token)
	var content = JSON.stringify({
		"username": Global.remaining_data.username,
		"token": Global.remaining_data.connection_token
	})
		
	var error = http_request.request(Global.api_url + "/auth/check_connectivity", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error(error, "An error occurred in the HTTP request.")
	await http_request.request_completed  # Wait for the request to finish

func _http_request_completed(result, response_code, headers, body): 
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	if(response["result"] == 1):
		Global.username = Global.remaining_data.username
	else: 
		SaveData.clear_all_saves()

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

# Function to check connectivity every 30 seconds
func periodic_connectivity_check() -> void:
	print("test")
	# Only check if we're logged in
	if Global.username == "" or remaining_data.connection_token == "":
		return
	
	var http_request = HTTPRequest.new()
	get_tree().root.add_child(http_request)
	http_request.request_completed.connect(_periodic_connectivity_completed)
	
	var content = JSON.stringify({
		"username": remaining_data.username,
		"token": remaining_data.connection_token
	})
	
	var error = http_request.request(api_url + "/auth/check_connectivity", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error(error, "An error occurred in the HTTP request.")

# Handle completion of periodic connectivity check
func _periodic_connectivity_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	# If not connected (result != 1), reset and go to home page
	if response.has("result") and response["result"] != 1:
		disconnect_user()

# Reset user variables and return to home page
func disconnect_user() -> void:
	# Reset user variables to default values
	Global.username = ""
	Global.avatar = -1
	Global.game_won = 0
	Global.game_played = 0
	Global.connection_token = ""
	Global.email = ""
	Global.online_game_id = 1000
	
	# Clear saved data
	SaveData.clear_all_saves()
	
	# Show disconnection message
	show_disconnection_message()
	
	# Navigate back to home page
	var current_scene = get_tree().current_scene
	if current_scene.name != "Login":
		get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")

# Display disconnection message to the user
func show_disconnection_message() -> void:
	# Create popup notification
	var popup = AcceptDialog.new()
	popup.title = "Connection Lost"
	popup.dialog_text = "You have been disconnected from your account."
	popup.dialog_autowrap = true
	
	# Set a proper size for the dialog
	var dialog_size = Vector2(300, 150) # Width of 300px, height of 150px
	popup.min_size = dialog_size
	
	get_tree().root.add_child(popup)
	popup.popup_centered(dialog_size) # Pass the size to popup_centered
	
	# Auto-remove popup after showing
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(popup):
		popup.queue_free()
