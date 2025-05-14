extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Vérifie si le mot de passe est suffisamment fort
func is_password_strong(password: String) -> bool:
	if password.length() < 8:
		return false

	var has_letter := false
	var has_digit := false
	var has_special := false

	for i in password.length():
		var c := password[i]
		var ascii := c.unicode_at(0)

		if ascii >= 48 and ascii <= 57:  # '0'-'9'
			has_digit = true
		elif (ascii >= 65 and ascii <= 90) or (ascii >= 97 and ascii <= 122):  # A-Z ou a-z
			has_letter = true
		elif c in "!@#$%^&*()-_=+[]{};:,.<>?/|\\~`":
			has_special = true

	return has_letter and has_digit and has_special
