extends Node

var lst_img = Global.card_images.duplicate()

func random_card():
	if lst_img.size() >0:
		print("test")
		var pos_carte_random=randi()%lst_img.size()
		var selected_card=lst_img[pos_carte_random]
		lst_img.remove_at(pos_carte_random)
		return selected_card
	else:
		return null
