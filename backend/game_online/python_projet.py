from debut_jeu import Card


class Combinaison:
    def __init__(self, combi, combi_value, combi_form):
        self.combi = combi
        self.combi_value = combi_value
        self.combi_form = combi_form

    def __eq__(self, other):
        return (
            self.combi == other.combi and
            self.combi_value == other.combi_value and
            self.combi_form == other.combi_form
        )


card_list = [
    "res://assets/cards/card_clubs_02.png",
    "res://assets/cards/card_clubs_03.png",
    "res://assets/cards/card_clubs_04.png",
    "res://assets/cards/card_clubs_05.png",
    "res://assets/cards/card_clubs_06.png",
    "res://assets/cards/card_clubs_07.png",
    "res://assets/cards/card_clubs_08.png",
    "res://assets/cards/card_clubs_09.png",
    "res://assets/cards/card_clubs_10.png",
    "res://assets/cards/card_clubs_A.png",
    "res://assets/cards/card_clubs_J.png",
    "res://assets/cards/card_clubs_K.png",
    "res://assets/cards/card_clubs_Q.png",
    "res://assets/cards/card_diamonds_02.png",
    "res://assets/cards/card_diamonds_03.png",
    "res://assets/cards/card_diamonds_04.png",
    "res://assets/cards/card_diamonds_05.png",
    "res://assets/cards/card_diamonds_06.png",
    "res://assets/cards/card_diamonds_07.png",
    "res://assets/cards/card_diamonds_08.png",
    "res://assets/cards/card_diamonds_09.png",
    "res://assets/cards/card_diamonds_10.png",
    "res://assets/cards/card_diamonds_A.png",
    "res://assets/cards/card_diamonds_J.png",
    "res://assets/cards/card_diamonds_K.png",
    "res://assets/cards/card_diamonds_Q.png",
    "res://assets/cards/card_hearts_02.png",
    "res://assets/cards/card_hearts_03.png",
    "res://assets/cards/card_hearts_04.png",
    "res://assets/cards/card_hearts_05.png",
    "res://assets/cards/card_hearts_06.png",
    "res://assets/cards/card_hearts_07.png",
    "res://assets/cards/card_hearts_08.png",
    "res://assets/cards/card_hearts_09.png",
    "res://assets/cards/card_hearts_10.png",
    "res://assets/cards/card_hearts_A.png",
    "res://assets/cards/card_hearts_J.png",
    "res://assets/cards/card_hearts_K.png",
    "res://assets/cards/card_hearts_Q.png",
    "res://assets/cards/card_spades_02.png",
    "res://assets/cards/card_spades_03.png",
    "res://assets/cards/card_spades_04.png",
    "res://assets/cards/card_spades_05.png",
    "res://assets/cards/card_spades_06.png",
    "res://assets/cards/card_spades_07.png",
    "res://assets/cards/card_spades_08.png",
    "res://assets/cards/card_spades_09.png",
    "res://assets/cards/card_spades_10.png",
    "res://assets/cards/card_spades_A.png",
    "res://assets/cards/card_spades_J.png",
    "res://assets/cards/card_spades_K.png",
    "res://assets/cards/card_spades_Q.png",
]


def check_higher_than_previous(previous_combi, new_combi):
    print(
        previous_combi.combi,
        previous_combi.combi_value,
        previous_combi.combi_form)
    print(new_combi.combi, new_combi.combi_value, new_combi.combi_form)
    if (previous_combi.combi <= 3):
        if (previous_combi.combi == new_combi.combi):
            if (new_combi.combi_value > previous_combi.combi_value):
                return True, ""
            else:
                if (new_combi.combi_value == previous_combi.combi_value and new_combi.combi_form >
                        previous_combi.combi_form):
                    return True, ""
                else:
                    return False, "Your combinaison is not higher than the previous one"
        else:
            return False, "Your combinaison doesn't follow the previous pattern"
    else:
        if (new_combi.combi > previous_combi.combi):
            return True, ""
        elif (new_combi.combi == previous_combi.combi):
            if (new_combi.combi_value > previous_combi.combi_value):
                return True, ""
            else:
                if (new_combi.combi_value == previous_combi.combi_value and new_combi.combi_form >
                        previous_combi.combi_form):
                    return True, ""
                else:
                    return False, "Your combinaison is not higher than the previous one"
        else:
            return False, "Your combinaison is not higher than the previous one"

# 1 : highest card
# 2 : pair
# 3 : Three of a kind
# 4 : Straight
# 5 : Flush
# 6 : Full house
# 7 : Four of a kind
# 8 : Straight flush


def combi_detection(card_clicked):
    combi = Combinaison(None, None, None)
    card_clicked.sort(key=lambda card: card.value)
    card_clicked.reverse()

    match len(card_clicked):
        case 1:
            combi.combi = 1
            combi.combi_value = card_clicked[0].value
            combi.combi_form = card_clicked[0].form
        case 2:
            if card_clicked[0].value == card_clicked[1].value:
                combi.combi = 2
                combi.combi_form = card_clicked[0].form
                combi.combi_value = card_clicked[0].value
        case 3:
            if len(
                    card_clicked) == 3 and card_clicked[0].value == card_clicked[1].value and card_clicked[1].value == card_clicked[2].value:
                combi.combi = 3
                combi.combi_value = card_clicked[0].value
                combi.combi_form = card_clicked[0].form
        case 5:
            value_list, form_list, suite = get_info(card_clicked)
            if suite == 5:
                if 5 in form_list:
                    combi.combi = 8
                    combi.combi_value = card_clicked[0].value
                    combi.combi_form = card_clicked[0].form
                else:
                    combi.combi = 4
                    combi.combi_value = card_clicked[0].value
                    combi.combi_form = card_clicked[0].form
            elif 5 in form_list:
                combi.combi = 5
                combi.combi_value = card_clicked[0].value
                combi.combi_form = card_clicked[0].form
            elif 2 in value_list and 3 in value_list:
                combi.combi = 6
                combi.combi_value = card_clicked[0].value
                combi.combi_form = card_clicked[0].form
            elif 4 in value_list:
                combi.combi = 7
                combi.combi_value = card_clicked[0].value
                combi.combi_form = card_clicked[0].form
    return combi


def get_info(card_clicked_sort):
    value_list = {}
    form_list = {}
    suite = 1
    suite_placeholder = 1
    previous_card = Card(None, None)

    for card in card_clicked_sort:
        if card.value in value_list:
            value_list[card.value] += 1
        else:
            value_list[card.value] = 1

        if card.form in form_list:
            form_list[card.form] += 1
        else:
            form_list[card.form] = 1

        if previous_card != Card(None, None):
            if previous_card.value - 1 == card.value:
                suite_placeholder += 1
            else:
                if suite_placeholder > suite:
                    suite = suite_placeholder
                suite_placeholder = 1

        previous_card = card

    if suite_placeholder > suite:
        suite = suite_placeholder

    return list(value_list.values()), list(form_list.values()), suite


if __name__ == "__main__":
    list_card = [Card(2, 2), Card(3, 2), Card(4, 2), Card(5, 2), Card(6, 2)]
    combi_detected = combi_detection(list_card)
    print(
        combi_detected.combi,
        combi_detected.combi_value,
        combi_detected.combi_form)
