extends Node2D

# Assuming these are the node paths to your LineEdit nodes
@onready var profile_name_line_edit = $ProfileName/LabelProfileName
@onready var email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword
var socket = WebSocketPeer.new()

func _on_create_account_pressed() -> void:
	# Assuming these are the variable names for the LineEdit nodes
	var profile_name = profile_name_line_edit.text
	var email = email_line_edit.text
	var password = password_line_edit.text

	# Now you have the values, you can use them as needed
	print("Profile Name: ", profile_name)
	print("Email: ", email)
	print("Password: ", password)
	print("CreateAccountClicked")
	
	var content = JSON.stringify({
		"function": "create_account",
		"data": {
			"profile_name": profile_name,
			"email": email,
			"password": password
		}})
		
	socket.send_text(content)
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")

func _on_login_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/LoginPage.tscn")

func _on_oauth_google_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("OAuthGoogleClicked")
	

func _on_hide_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		if password_line_edit.is_secret():
			password_line_edit.set_secret(false)
		else:
			password_line_edit.set_secret(true)
		

func _on_tree_exited() -> void:
	socket.close()

func _ready() -> void:
	print("hello")
	var err = socket.connect_to_url(Global.websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			print("Packet: ", socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
