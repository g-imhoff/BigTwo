extends Node2D

@onready var code_fields = [
	$HBoxContainer/LineEdit1,
	$HBoxContainer/LineEdit2,
	$HBoxContainer/LineEdit3,
	$HBoxContainer/LineEdit4,
	$HBoxContainer/LineEdit5,
	$HBoxContainer/LineEdit6,
]

@onready var submit_button = $SubmitBtn



func _ready():
	for i in range(code_fields.size()):
		var field = code_fields[i]
		field.max_length = 1
		field.connect("text_changed", Callable(self, "_on_code_input").bind(i))
	_check_code_filled()
func _on_code_input(new_text: String, index: int):
	if new_text.length() == 1 and !new_text.is_valid_int():
		code_fields[index].text = ""
	elif new_text.length() == 1:
		if index < code_fields.size() - 1:
			code_fields[index + 1].grab_focus()
	_check_code_filled()

func _check_code_filled():
	for field in code_fields:
		if field.text.length() != 1 or !field.text.is_valid_int():
			_set_submit_button_state(false)
			return
	_set_submit_button_state(true)

func _set_submit_button_state(enabled: bool):
	if enabled:
		submit_button.set_disabled(false)
	else:
		submit_button.set_disabled(true)
