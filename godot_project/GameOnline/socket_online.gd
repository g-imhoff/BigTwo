extends Node

var socket = WebSocketPeer.new()
var room_name = ""
var host_name = ""
var players_name = []

var id = 0
var list_id = []
var card_hand = []
var first_player = false
