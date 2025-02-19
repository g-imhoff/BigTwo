extends Node2D

@onready var profile_name_email_line_edit = $Email/LabelEmail
@onready var password_line_edit = $Password/LabelPassword
@onready var rememberme_checkbox = $RememberMe



func _on_oauth_google_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("OAuthGoogleClicked")
	
	pass # Replace with function body.


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

	# You can add further logic here, such as sending these values to a server,
	# saving them locally, or performing validation.
	pass # Replace with function body.


func _on_create_account_pressed() -> void:
	get_tree().change_scene_to_file("res://CreatePage.tscn")
	pass # Replace with function body.


func _on_hide_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		if password_line_edit.is_secret():
			password_line_edit.set_secret(false)
		else:
			password_line_edit.set_secret(true)
		
	pass # Replace with function body.
