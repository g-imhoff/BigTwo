extends Node2D

@onready var winnertext = $PlayerWinner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/HomePage.tscn")
	pass # Replace with function body.


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://GameOnline/scenes/Lobby.tscn")
	pass # Replace with function body.

func show_popup(winner): 
	winnertext.text = winner + " Won !"
	
