class Card:
    def __init__(self, value, form):
        self.value = value
        self.form = form

def get_list_card_info_from_texture(l): 
    result = []
    i = 0
    for path in l:
        form, value = get_card_info_from_texture(path)
        card = Card(value, form)
        result.append(card)
        i += 1

    return result

def get_card_info_from_texture(path):
    form = -1 
    if path.find("clubs")!=-1:
        form=2
    elif path.find("diamonds")!=-1:
        form=1
    elif path.find("hearts")!=-1:
        form=3
    elif path.find("spades")!=-1:
        form=4

    value_str=path.split("_")[2].split(".")[0]
    value = -1

    if value_str=="A":
        value=14
    elif value_str=="K":
        value=13
    elif value_str=="Q":
        value=12
    elif value_str=="J":
        value=11
    elif value_str=="02":
        value=15
    elif value_str.isnumeric() :
        value = int(value_str)

    return form, value 
