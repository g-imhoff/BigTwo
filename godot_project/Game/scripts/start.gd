extends Node

@onready var hand = get_node_or_null("../PlayerHand")
@onready var hand_left = get_node_or_null("../EnemyHandLeft")
@onready var hand_up = get_node_or_null("../EnemyHandUp")
@onready var hand_right = get_node_or_null("../EnemyHandRight")


@onready var player_hand_script = $"../card_manager"
@onready var enemy_hand_left_script = $"../card_manager_enemy_left"
@onready var enemy_hand_up_script = $"../card_manager_enemy"
@onready var enemy_hand_right_script = $"../card_manager_enemy_right"


func _ready() -> void:
	var card_found = check_for_card(3, "diamonds", hand.player_hand, player_hand_script)
	if not card_found:
		card_found = check_for_card(3, "diamonds", hand_left.player_hand, enemy_hand_left_script)
	if not card_found:
		card_found = check_for_card(3, "diamonds", hand_up.player_hand, enemy_hand_up_script)
	if not card_found:
		check_for_card(3, "diamonds", hand_right.player_hand, enemy_hand_right_script)

# Fonction générique pour vérifier la présence de la carte et appeler la méthode sur le script
func check_for_card(value: int, form: String, hand: Array, script: Node) -> bool:
	script.played=true
	for card in hand:
		if card.value == value and card.form == form:
			script.on_card_played()
			script.played=false
			return true  # Sortir dès qu'on trouve la carte pour éviter des appels multiples
	return false
