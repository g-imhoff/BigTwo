extends Node2D

@onready var profile_name_email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword
@onready var rememberme_checkbox = $RememberMe
@onready var accverificationpopup = $Accverificationpop

var Hash = load("res://hashage.gd")

func _on_oauth_google_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("OAuthGoogleClicked")

func _on_login_pressed() -> void:
	# Assuming these are the variable names for the LineEdit nodes
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	
	var profile_name_email = profile_name_email_line_edit.text
	var password = password_line_edit.text
	var rememberme = rememberme_checkbox.is_pressed()
	var password_hash = ""
	
	if password != "":
		password_hash = Hash.hash_password(password)
	
	var content = JSON.stringify({
		"username_email": profile_name_email,
		"password": password_hash, 
		"rememberme": rememberme,
		"token": Global.remaining_data.connection_token
	})
		
	var error = http_request.request(Global.api_url + "/auth/login", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_create_account_pressed() -> void: 
	get_tree().change_scene_to_file("res://GameStarter/CreatePage.tscn")

func _ready() -> void:
	UISounds.install_sounds(self)

func _http_request_completed(result, response_code, headers, body): 
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	if (response["code"] == 0):
		# Needs to setup a token of connection
		Global.username = response["username"]
		Global.connection_token = response["connection_token"]
		
		if response["rememberme"]:
			Global.remaining_data.username = response["username"]
			Global.remaining_data.connection_token = response["connection_token"]
			Global.remaining_data.save_to_disk()
		
		get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")
	elif (response["code"] == 5): 
		Global.email = response["email"]
		accverificationpopup.visible = true
	else :
		Notification.show_side(response["message"])


func _on_back_button_login_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ConnectionPage.tscn")

func _on_texture_button_pressed() -> void:
		print("OAuthGoogleClicked")

func _on_reset_pass_btn_pressed() -> void:
	$ForgotPasswordPopup.visible = not $ForgotPasswordPopup.visible
