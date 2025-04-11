class Combinaison:
    def __init__(self, combi, combi_value,combi_form):
        self.combi = combi
        self.combi_value = combi_value
        self.combi_form = combi_form

# 4: Straight
# 5: flush
# 6: full house
# 7: four of a kind
# 8: Straight flush
def check_higher_than_previous(previous_combi, new_combi):
    print(previous_combi.combi, previous_combi.combi_value, previous_combi.combi_form)
    print(new_combi.combi, new_combi.combi_value, new_combi.combi_form)
    if (previous_combi.combi <= 3):
        if (previous_combi.combi == new_combi.combi):
            if (new_combi.combi_value > previous_combi.combi_value): 
                return True, ""
            else :
                if (new_combi.combi_value == previous_combi.combi_value and new_combi.combi_form > previous_combi.combi_form):
                    return True, ""
                else :
                    return False, "Your combinaison is not higher than the previous one"
        else : 
            return False, "Your combinaison doesn't follow the previous pattern"
    else:
        if (new_combi.combi > previous_combi.combi):
            return True, ""
        elif (new_combi.combi == previous_combi.combi):
            if (new_combi.combi_value > previous_combi.combi_value): 
                return True, ""
            else :
                if (new_combi.combi_value == previous_combi.combi_value and new_combi.combi_form > previous_combi.combi_form):
                    return True, ""
                else :
                    return False, "Your combinaison is not higher than the previous one"
        else : 
            return False, "Your combinaison is not higher than the previous one"

def check_card_clicked(card_clicked):
    check=None
    combi=None
    if len(card_clicked) == 1:
        check=1
        combi=1
        combi_value=card_clicked[0].value
        combi_form=card_clicked[0].form 
    elif len(card_clicked) == 2 and card_clicked[0].value==card_clicked[1].value:
        check=2
        combi=2
        combi_value=card_clicked[0].value
        lst_tmp=[]
        lst_tmp = card_clicked.copy() 
        lst_tmp.sort(key=lambda card: card.form)
        combi_form=card_clicked[0].form
    elif len(card_clicked) == 3 and card_clicked[0].value == card_clicked[1].value and card_clicked[1].value == card_clicked[2].value:
        check=3
        combi=3
        combi_value=card_clicked[0].value
        lst_tmp=[]
        lst_tmp = card_clicked.copy() 
        lst_tmp.sort(key=lambda card: card.form)
        combi_form=card_clicked[0].form
    elif len(card_clicked)==5:
        card_clicked.sort(key=lambda card: card.value)
        val=0
        signe=0
        suite=0
        tab_check_brelan=[]
        tmp=0
        tmp_tab=tab_check_brelan.copy()
        tmp_tab.append(card_clicked[0])
        for i in range(len(card_clicked)-1):
            if card_clicked[i].value== card_clicked[i+1].value:
                tmp+=1
                tmp_tab.append(card_clicked[i+1])
            elif card_clicked[i].value!= card_clicked[i+1].value or i+1==len(card_clicked)-1:
                val=tmp
                if tab_check_brelan.size()<2:
                    tab_check_brelan=tmp_tab.copy()
                tmp=0
            if card_clicked[i].form==card_clicked[i+1].form:
                signe+=1
            if card_clicked[i+1].value== card_clicked[i].value+1:
                suite+=1
        if val == 3:#check Four of a Kind
            check=7
            combi=7
            val_tmp=card_clicked[0]
            if card_clicked[0]!=card_clicked[1]:
                val_tmp=card_clicked[1]
            combi_value=val_tmp.value
            combi_form=val_tmp.form
        elif suite==4 and signe ==4:#check pour Straight Flush
            check =8 
            combi=8
            combi_value=card_clicked[4].value
            combi_form=card_clicked[4].form
        elif signe==4:#check Flush
            check= 5
            combi=5
            combi_value=card_clicked[4].value
            combi_form=card_clicked[4].form
        elif suite==4:#check pour straight
            check =4
            combi=4
            combi_value=card_clicked[4].value
            combi_form=card_clicked[4].form
        elif val == 1 or val == 2:  # check pour full house
            tab_val = card_clicked.copy()
            for i in range(len(tab_check_brelan)):
                tab_val.remove(tab_check_brelan[i])
            if val == 2:
                brelan=tab_check_brelan.duplicate()
                if tab_val[0].value == tab_val[1].value:
                    check = 6
                    combi=6
                    combi_value=brelan[0].value
                    combi_form=brelan[0].form		
            elif val == 1:
                brelan=tab_val.copy()
                if len(tab_val) == 3 and tab_val[0].value == tab_val[1].value:  # Assure que seulement 2 cartes restent
                    combi=6
                    check = 6
                    combi_value=tab_val[0].value
                    combi_form=tab_val[0].form
    return check




    
