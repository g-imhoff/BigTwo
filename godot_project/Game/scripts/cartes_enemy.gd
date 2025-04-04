extends Node2D

signal hovered
signal hovered_off 

var hand_position
var value
var form
var img

func _ready() -> void:
	#chaque carte doit être un enfant de card_manager sinon erreur
	UISounds.install_sounds(self)

	pass
