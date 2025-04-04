extends CanvasLayer

@export var side_label_node : PackedScene = preload("res://sprite/SideLabel.tscn")
@onready var side = $SideBox

func show_side(message):
	var side_label : Label = side_label_node.instantiate()
	side_label.text = message
	side.add_child(side_label)
	
	var tween : Tween = side_label.create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(side_label.queue_free)
	
