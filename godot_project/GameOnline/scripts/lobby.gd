extends Node2D

func _ready() -> void:
	var clientCAS = load("res://cert.crt")
	var err = SocketOnline.socket.connect_to_url(Global.server_url, TLSOptions.client_unsafe(clientCAS))
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		while SocketOnline.socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			SocketOnline.socket.poll()
			await get_tree().create_timer(0.1).timeout # Small delay to prevent CPU overload

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://GameStarter/ChooseModePage.tscn")

func _on_create_room_btn_pressed() -> void:
	$Pokerboard/Createroompop.visible = not $Pokerboard/Createroompop.visible

func _on_join_room_btn_pressed() -> void:
	$Pokerboard/Joinroompop.visible = not $Pokerboard/Joinroompop.visible
