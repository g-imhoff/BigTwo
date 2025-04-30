extends Node2D

@onready var room_name_form = $LobbyPopUp/RoomName
@onready var password_form = $LobbyPopUp/Password

var Hash = load("res://hashage.gd")

func _on_cancel_btn_pressed() -> void:
	$".".visible = not $".".visible

func _on_create_btn_pressed() -> void:
	var password_hashed = ""
	if password_form.text != "":
		password_hashed = Hash.hash_password(password_form.text)	

	var content = JSON.stringify({
		"function": "create_room",
		"host_name": Global.username,
		"room_name": room_name_form.text,
		"password": password_hashed
	})
	
	SocketOnline.socket.send_text(content)
