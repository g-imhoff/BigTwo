extends Node2D

# Assuming these are the node paths to your LineEdit nodes
@onready var profile_name_line_edit = $ProfileName/LabelProfileName
@onready var email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword


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
	
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")
	# You can add further logic here, such as sending these values to a server,
	# saving them locally, or performing validation.


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
		

# The URL we will connect to.
@export var websocket_url = "ws://localhost:18014/"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

func _ready():
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()
