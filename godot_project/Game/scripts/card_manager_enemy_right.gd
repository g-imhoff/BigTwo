extends Node2D

signal enemy

const COLLISION_MASK_CARD=1
const COLLISION_MASK_SLOT=2

var screen_size
var is_hovering_on_card
var num_card_up=0
var card_clicked=[]
var cmpt_card_in_slot=0
var played=false
var lst_card_in_slot=[]

@onready var hand=$"../EnemyHandRight"
@onready var Cardslots=$"../Cardslots4"
@onready var children_slots=Cardslots.get_children()
@onready var Cardslots_right=$"../Cardslots2"
@onready var children_slots_right=Cardslots_right.get_children()
@onready var bot_player_func=$"../bot_player_func"
@onready var timer = $"../Timer"
@onready var circle_sprite=$"../EnemyUsernameRight/EnemySpriteRight"
var player="right"

func _ready() -> void:
	screen_size=get_viewport_rect().size

func on_card_played():
	circle_sprite.visible=true
	timer.start(2.0)
	await timer.timeout
	bot_player_func.on_card_played(children_slots_right, children_slots, played, hand, cmpt_card_in_slot, lst_card_in_slot,player)
	timer.start(2.0)
	await timer.timeout
	circle_sprite.visible=false
	emit_signal("enemy")



func _on_card_manager_enemy_enemy_right() -> void:
	played=false
	bot_player_func.remove_card_in_slot(lst_card_in_slot, children_slots, cmpt_card_in_slot)
	on_card_played()
