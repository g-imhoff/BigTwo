extends Node

func _ready():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
