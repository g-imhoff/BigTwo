extends Node2D
@onready var room_name = $RoomName
@onready var nb_users = $NbOfUsers

func set_values(room_name, nb_players): 
	room_name.text = room_name
	nb_users.text = nb_users
