class Card:
    def __init__(self, value, form):
        self.value = value
        self.form = form


def get_card_info_from_texture(path):
	card_info=[]
	
	if path.find("clubs")!=-1:
		card_info[0]=2
	elif path.find("diamonds")!=-1:
		card_info[0]=1
	elif path.find("hearts")!=-1:
		card_info[0]=3
	elif path.find("spades")!=-1:
		card_info[0]=4
	
	value_str=path.split("_")[2].split(".")[0]
	
	if value_str=="A":
		card_info[1]=14
	elif value_str=="K":
		card_info[1]=13
	elif value_str=="Q":
		card_info[1]=12
	elif value_str=="J":
		card_info[1]=11
	elif value_str=="02":
		card_info[1]=15
	elif value_str.is_valid_float():
		card_info[1] = int(value_str)
	return card_info