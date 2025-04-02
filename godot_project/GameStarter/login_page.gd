extends Node2D

@onready var profile_name_email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword
@onready var rememberme_checkbox = $RememberMe
var socket = WebSocketPeer.new()

var HasH = load("res://hashage.gd")

func _on_oauth_google_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("OAuthGoogleClicked")

func _on_login_pressed() -> void:
	# Assuming these are the variable names for the LineEdit nodes
	var profile_name_email = profile_name_email_line_edit.text
	var password = password_line_edit.text
	var rememberme = rememberme_checkbox.is_pressed()

	var password_hash = HasH.hash_password(password) #Hashing 
	
	var content = JSON.stringify({
	"function": "login",
	"data": {
		"profile_name_email": profile_name_email,
		"password": password_hash
	}})
		
	socket.send_text(content)


func _on_create_account_pressed() -> void: 
	get_tree().change_scene_to_file("res://GameStarter/CreatePage.tscn")


func _on_hide_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		if password_line_edit.is_secret():
			password_line_edit.set_secret(false)
		else:
			password_line_edit.set_secret(true)

func _ready() -> void:
	var clientCAS = load("res://cert.crt")
	var err = socket.connect_to_url(Global.websocket_url, TLSOptions.client_unsafe(clientCAS))
	if err != OK:
		print("Unable to connect")
		set_process(false)
		
func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN: 
		while socket.get_available_packet_count():
			_data_received_handler(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func _data_received_handler(data):
	if (data["code"] == 0):
		# Needs to setup a token of connection
		Global.username = data["username"]
		get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")
	else :
		Notification.show_side(data["message"])

func _on_tree_exited() -> void:
	socket.close()
