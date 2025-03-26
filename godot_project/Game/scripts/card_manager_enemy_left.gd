extends Node2D

signal enemy_up

const COLLISION_MASK_CARD=1
const COLLISION_MASK_SLOT=2

var screen_size
var is_hovering_on_card
var num_card_played=0
var card_clicked=[]
var cmpt_card_in_slot=0
var played=false
var lst_card_in_slot=[]

@onready var hand=$"../EnemyHandLeft"
@onready var Cardslots=$"../Cardslots3"
@onready var children_slots=Cardslots.get_children()
@onready var Cardslots_right=$"../Cardslots"
@onready var children_slots_right=Cardslots_right.get_children()
@onready var bot_player_func=$"../bot_player_func"



func _ready() -> void:
	screen_size=get_viewport_rect().size

func on_card_played():
	await get_tree().create_timer(2.0).timeout
	bot_player_func.on_card_played(children_slots_right, children_slots, played, hand, cmpt_card_in_slot, lst_card_in_slot)
	print(children_slots[0].combi)
	emit_signal("enemy_up")

func _on_card_manager_card_played() -> void:
	played=false
	bot_player_func.remove_card_in_slot(lst_card_in_slot, children_slots, cmpt_card_in_slot)
	on_card_played()
