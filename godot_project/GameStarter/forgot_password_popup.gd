extends Node2D

@onready var labelemail: LineEdit = $PopupSettings/Email2/LabelEmail
@onready var labelcode: LineEdit = $PopupSettings/Code3/LabelCode
@onready var labelnewpassword: LineEdit = $PopupSettings/NewPassword4/LabelNewPassword

var email = ""
var Hash = load("res://hashage.gd")

func _on_back_button_login_pressed() -> void:
	$".".visible = not $".".visible

func _on_submit_btn_pressed() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	email = labelemail.text
	
	var content = JSON.stringify({
		"email": email,
	})
		
	var error = http_request.request(Global.api_url + "/auth/send_email_reset_password", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body): 
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	if(response["function"] == "send_email_reset_password"):
		if(response["code"] != 0):
			Notification.show_side(response["message"])
	elif(response["function"] == "reset_password"):
		if(response["code"] == 0): 
			self.visible = false
			Notification.show_side("Password has been changed successfully")
		else : 
			Notification.show_side(response["message"])

func _on_reset_btn_pressed() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	var password = labelnewpassword.text
	var password_hash = ""
	
	if password != "":
		password_hash = Hash.hash_password(password)	
	
	var content = JSON.stringify({
		"email": email if email != "" else labelemail.text,
		"new_password": password_hash,
		"reset_password_code": labelcode.text
	})
		
	var error = http_request.request(Global.api_url + "/auth/reset_password", [], HTTPClient.METHOD_POST, content)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
