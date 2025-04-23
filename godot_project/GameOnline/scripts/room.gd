extends Node2D

@onready var room_name: Label = $RoomName
@onready var nb_users: Label = $NbOfUsers

func set_values(init_room_name, nb_players): 
	room_name.text = init_room_name
	nb_users.text = str(nb_players)
