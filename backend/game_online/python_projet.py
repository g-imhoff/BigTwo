

class Combinaison:
    def __init__(self, combi, combi_value,combi_form):
        self.combi = combi
        self.combi_value = combi_value
        self.combi_form = combi_form

enemy_combi=Combinaison(None,None,None)
my_combi=Combinaison(None,None,None)
brelan=[]

def check_other_cards(card_clicked):
    lst_card=card_clicked.copy()
    check_combi=check_card_clicked(card_clicked)
    card_clicked.sort(key=lambda card: card.value)
    if enemy_combi.combi==None and check_combi!=None:
        return True
    combi_enemy=None
    combi_enemy=enemy_combi.combi
    if isinstance(check_combi, type(combi_enemy)) and check_combi is not None:
        if (check_combi == "1" or check_combi == "2" or check_combi =="3"):
            if lst_card[0].value >enemy_combi.combi_value or (lst_card[0].value == enemy_combi.combi_value and lst_card[0].form > enemy_combi.combi_form):
                return True
            lst_card.sort(key=lambda card: card.form)
            if (lst_card[0].value==enemy_combi.combi_value and lst_card[0].form>enemy_combi.combi_form ):
                return True
        elif check_combi=="four of a kind":
            val_a_check=lst_card[0]
            if val_a_check!=lst_card[1]:
                val_a_check=lst_card[1]
            if (val_a_check.value > enemy_combi.combi_value) or (enemy_combi.combi=="full house" or enemy_combi.combi=="flush" or enemy_combi.combi=="straight"):
                return True
        elif check_combi=="straight flush":
            if (lst_card[4].value >enemy_combi.combi_value and lst_card[4].form >enemy_combi.combi_form) or (lst_card[4].value==enemy_combi.combi_value and lst_card[4].form==enemy_combi.combi_form ) or (enemy_combi.combi=="four of a kind" or enemy_combi.combi=="full house" or enemy_combi.combi=="flush" or enemy_combi.combi=="straight"):
                return True
        elif check_combi=="straight":
            if lst_card[4].value >enemy_combi.combi_value or (lst_card[4].value==enemy_combi.combi_value and lst_card[4].form==enemy_combi.combi_form ):
                return True
        elif check_combi=="flush":
            if (lst_card[4].value >enemy_combi.combi_value or (lst_card[4].value==enemy_combi.combi_value and lst_card[4].form==enemy_combi.combi_form )) or (enemy_combi.combi=="straight"):
                return True
        elif check_combi=="full house":
            if brelan[0].value>enemy_combi.combi_value or (enemy_combi.combi=="straight" or enemy_combi.combi=="flush"):
                return True
    enemy_combi.combi=None
    return False

def check_card_clicked(card_clicked):
    check=None
    combi=None
    if len(card_clicked) == 1:
        check="1"
        combi="1"
        combi_value=card_clicked[0].value
        combi_form=card_clicked[0].form 
    elif len(card_clicked) == 2 and card_clicked[0].value==card_clicked[1].value:
        check="2"
        combi="2"
        combi_value=card_clicked[0].value
        lst_tmp=[]
        lst_tmp = card_clicked.copy() 
        lst_tmp.sort(key=lambda card: card.form)
        combi_form=card_clicked[0].form
    elif len(card_clicked) == 3 and card_clicked[0].value == card_clicked[1].value and card_clicked[1].value == card_clicked[2].value:
        check="3"
        combi="3"
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
            check="four of a kind"
            combi="four of a kind"
            val_tmp=card_clicked[0]
            if card_clicked[0]!=card_clicked[1]:
                val_tmp=card_clicked[1]
            combi_value=val_tmp.value
            combi_form=val_tmp.form
        elif suite==4 and signe ==4:#check pour Straight Flush
            check ="straight flush" 
            combi="straight flush"
            combi_value=card_clicked[4].value
            combi_form=card_clicked[4].form
        elif signe==4:#check Flush
            check= "flush"
            combi="flush"
            combi_value=card_clicked[4].value
            combi_form=card_clicked[4].form
        elif suite==4:#check pour straight
            check ="straight"
            combi="straight"
            combi_value=card_clicked[4].value
            combi_form=card_clicked[4].form
        elif val == 1 or val == 2:  # check pour full house
            tab_val = card_clicked.copy()
            for i in range(len(tab_check_brelan)):
                tab_val.remove(tab_check_brelan[i])
            if val == 2:
                brelan=tab_check_brelan.duplicate()
                if tab_val[0].value == tab_val[1].value:
                    check = "full house"
                    combi="full house"
                    combi_value=brelan[0].value
                    combi_form=brelan[0].form		
            elif val == 1:
                brelan=tab_val.copy()
                if len(tab_val) == 3 and tab_val[0].value == tab_val[1].value:  # Assure que seulement 2 cartes restent
                    combi="full house"
                    check = "full house"
                    combi_value=tab_val[0].value
                    combi_form=tab_val[0].form
    return check




    
