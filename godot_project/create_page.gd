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

	# You can add further logic here, such as sending these values to a server,
	# saving them locally, or performing validation.
	pass # Replace with function body.


func _on_login_pressed() -> void:
	get_tree().change_scene_to_file("res://LoginPage.tscn")
	pass # Replace with function body.


func _on_oauth_google_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		print("OAuthGoogleClicked")
	
	pass # Replace with function body.


func _on_hide_button_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("leftclick"):
		if password_line_edit.is_secret():
			password_line_edit.set_secret(false)
		else:
			password_line_edit.set_secret(true)
		
	pass # Replace with function body.
