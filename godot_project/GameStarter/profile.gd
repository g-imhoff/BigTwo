extends Node2D

var avatar_path = [
	"res://assets/ui/10.png",
	"res://assets/ui/18.png",
	"res://assets/ui/19.png",
	"res://assets/ui/21.png",
	"res://assets/ui/23.png",
	"res://assets/ui/24.png",
]
@onready var games_label = $games
@onready var wins_label = $wins

func _ready():
	UISounds.install_sounds(self)

	# Set p"res://assets/ui/18.png"reviously selected avatar if any
	var texture = load(avatar_path[Global.avatar])
	$AvatarImage.texture = texture
	games_label = Global.game_played
	wins_label = Global.game_won

	# Dynamically connect all TextureButtons in AvatarPopup
	for button in $AvatarPopup/PopupSettings.get_children():
		if button is TextureButton:
			button.pressed.connect(_on_avatar_button_pressed.bind(button))

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")

func _on_change_avatar_pressed() -> void:
	$AvatarPopup.visible = not $AvatarPopup.visible

func _on_avatar_button_pressed(button: TextureButton) -> void:
	Global.avatar = button.get_meta("id")
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	
	var content = JSON.stringify({
		"username": Global.username,
		"avatar": Global.avatar
	})
		
	var error = http_request.request(Global.api_url + "/user/change_avatar", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	await http_request.request_completed
	
	$AvatarPopup.hide()


func _http_request_completed(result, response_code, headers, body): 
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	if (response["code"] == 0):
		var texture = load(avatar_path[Global.avatar])
		$AvatarImage.texture = texture
	else:
		Notification.show_side(response["message"])


func _on_disconnect_pressed() -> void:
	SaveData.clear_all_saves()
	Global.username = ""
	Global.email = ""
	Global.connection_token = ""
	Global.remaining_data.username = ""
	Global.remaining_data.connection_token = ""
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
