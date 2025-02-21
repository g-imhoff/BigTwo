extends Node2D

signal hovered
signal hovered_off 

var hand_position
var value
var form

func _ready() -> void:
	#chaque carte doit être un enfant de card_manager sinon erreur
	get_parent().connect_card_signals(self)

func _process(delta: float) -> void:
	pass



func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
