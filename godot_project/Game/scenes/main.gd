extends Node2D


func _on_settings_btn_pressed() -> void:
	$Setting.visible = not $Setting.visible


func _on_texture_button_pressed() -> void:
	$Rules_Popup.visible = not $Rules_Popup.visible

var lst_img = Global.card_images.duplicate()

func random_card():
	if lst_img.size() >0:
		var pos_carte_random=randi()%lst_img.size()
		var selected_card=lst_img[pos_carte_random]
		lst_img.remove_at(pos_carte_random)
		return selected_card
	else:
		return null
