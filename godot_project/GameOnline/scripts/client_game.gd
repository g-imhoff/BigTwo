extends Node2D

var socket = WebSocketPeer.new()

func _on_tree_exited() -> void:
	socket.close()

func _ready() -> void:
	var clientCAS = load("res://cert.crt")
	var err = socket.connect_to_url(Global.server_url, TLSOptions.client_unsafe(clientCAS))
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		_server_handshake()

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN: 
		while socket.get_available_packet_count():
			_data_received_handler(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func _data_received_handler(data):
	print(data["code"])

func _server_handshake():
	var content = JSON.stringify({
		"function": "connect",
		"profile_name": Global.username
	})
	
	socket.send_text(content)
