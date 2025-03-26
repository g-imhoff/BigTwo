extends Node

@onready var sounds = {
	"UI_Hover": AudioStreamPlayer.new(),
	"UI_Click": AudioStreamPlayer.new(),
}

func _ready():
	# Charger les sons et les ajouter à la scène
	for key in sounds.keys():
		var player = sounds[key]
		player.stream = load("res://assets/sounds/" + key + ".ogg")  # adapte le chemin
		player.bus = "Master"  # ou "Sfx" si tu utilises un bus custom
		add_child(player)

func install_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is Button or child is TextureButton or child is OptionButton:
			child.pressed.connect(ui_sfx_play.bind("UI_Click"))
			child.mouse_entered.connect(ui_sfx_play.bind("UI_Hover"))
		elif child is TabContainer:
			child.tab_clicked.connect(ui_sfx_play.bind("UI_Click"))
			child.tab_hovered.connect(ui_sfx_play.bind("UI_Hover"))
		
		# Appel récursif pour enfants
		install_sounds(child)

func ui_sfx_play(sound: String) -> void:
	if sound in sounds:
		sounds[sound].play()
