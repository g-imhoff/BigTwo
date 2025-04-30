extends Node2D

@onready var room_name: Label = $RoomName
@onready var nb_users: Label = $NbOfUsers
@onready var password_label = $Password
var Hash = load("res://hashage.gd")

func set_values(init_room_name, nb_players): 
	room_name.text = init_room_name
	nb_users.text = str(nb_players)

func _on_join_pressed() -> void:
	var password_hash = ""
	
	if password_label.text != "":
		password_hash = Hash.hash_password(password_label.text)
	
	var message = JSON.stringify({
		"function": "join_room", 
		"room_name": room_name.text,
		"username": Global.username,
		"password": password_hash
	})
	
	SocketOnline.socket.send_text(message)
