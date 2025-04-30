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
@onready var resend_button = $"resend code"
@onready var cooldown_timer = $Timer
@onready var cooldown_label = $CooldownLabel

var remaining_seconds := 60

func _ready():
	var file = FileAccess.open("res://data.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var data = JSON.parse_string(json_string)
	
	for i in range(code_fields.size()):
		var field = code_fields[i]
		field.max_length = 1
		field.connect("text_changed", Callable(self, "_on_code_input").bind(i))
	_check_code_filled()
	
	# Start cooldown on popup ready
	start_cooldown()

func _on_code_input(new_text: String, index: int):
	if new_text.length() == 1 and !new_text.is_valid_int():
		code_fields[index].text = ""
	elif new_text.length() == 1:
		if index < code_fields.size() - 1:
			code_fields[index + 1].grab_focus()
	var code := ""
	if (_check_code_filled()):
		for field in code_fields:
			code += field.text
		_set_submit_button_state(true)
	_set_submit_button_state(false)

func _check_code_filled():
	for field in code_fields:
		if field.text.length() != 1 or !field.text.is_valid_int():
			return false
	return true


func _set_submit_button_state(enabled: bool):
	submit_button.disabled = !enabled

func start_cooldown():
	remaining_seconds = 60
	resend_button.disabled = true
	cooldown_label.visible = true
	cooldown_label.text = str(remaining_seconds) + "s"
	cooldown_timer.wait_time = 1
	cooldown_timer.start()

func _on_timer_timeout() -> void:
	remaining_seconds -= 1
	if remaining_seconds > 0:
		cooldown_label.text = str(remaining_seconds) + "s"
	else:
		cooldown_timer.stop()
		resend_button.disabled = false
		cooldown_label.visible = false

func _on_resend_code_pressed() -> void:
	# Your resend code logic here (e.g., socket.send_text or API call)
	start_cooldown()

func check_code_correct(test_code : String, data):
	for field in code_fields:
		test_code += field.text
	if (test_code == data[0]):
		return true
	else:
		return false
