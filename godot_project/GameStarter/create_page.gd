extends Node2D

# Assuming these are the node paths to your LineEdit nodes
@onready var profile_name_line_edit = $ProfileName/LabelProfileName
@onready var email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword
@onready var accverifi_popup = $Accverificationpop

var Hash = load("res://hashage.gd")

func _on_create_account_pressed() -> void:
	# Assuming these are the variable names for the LineEdit nodes
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	
	var profile_name = profile_name_line_edit.text
	var email = email_line_edit.text
	var password = password_line_edit.text
	var password_hash = ""
	
	if password != "":
		password_hash = Hash.hash_password(password)	
		
	var content = JSON.stringify({
		"username": profile_name,
		"email": email,
		"password": password_hash
	})
		
	var error = http_request.request(Global.api_url + "/auth/register", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_login_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/LoginPage.tscn")
	
	var Accverification = $Accverificationpop
	if Accverification:
		Accverification.visible = true

func _ready() -> void:
	UISounds.install_sounds(self)

func _http_request_completed(result, response_code, headers, body): 
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	if(response["code"] == 0):
		accverifi_popup.visible = true
		Global.email = response["email"]
	else :
		Notification.show_side(response["message"])

func _on_backicon_connection_page_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ConnectionPage.tscn")
