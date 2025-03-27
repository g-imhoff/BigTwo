extends Node2D

@onready var profile_name_email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword
@onready var rememberme_checkbox = $RememberMe
var socket = WebSocketPeer.new()



func _on_login_pressed() -> void:
	# Assuming these are the variable names for the LineEdit nodes
	var profile_name_email = profile_name_email_line_edit.text
	var password = password_line_edit.text
	var rememberme = rememberme_checkbox.is_pressed()

	# Now you have the values, you can use them as needed
	print("Profile Name: ", profile_name_email)
	print("Password: ", password)
	print("Remember me: ", rememberme)
	print("LoginAccountClicked")
	
	var content = JSON.stringify({
	"function": "login",
	"data": {
		"profile_name_email": profile_name_email,
		"password": password
	}})
		
	socket.send_text(content)
	# This is to delete when we will add the login method
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")


func _on_create_account_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/CreatePage.tscn")


func _ready() -> void:
	print("hello")
	var err = socket.connect_to_url(Global.websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
		
	UISounds.install_sounds(self)

func _process(_delta):
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


func _on_tree_exited() -> void:
	socket.close()


func _on_back_button_login_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ConnectionPage.tscn")


func _on_texture_button_pressed() -> void:
		print("OAuthGoogleClicked")
