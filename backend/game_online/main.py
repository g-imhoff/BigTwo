import asyncio
import random
import json
from websockets.asyncio.server import serve
import ssl
from debut_jeu import get_list_card_info_from_texture
from python_projet import check_card_clicked, Combinaison, check_higher_than_previous

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(
    certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "0.0.0.0"  # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT = 10006

connected_client = {}
nb_client = 0

last_combi = None 

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

placeholder_card_list = card_list.copy()

'''
All the function : 

    - server : 
        - connected : help to the client to know that the connection worked well
        - starting : start the game with everything needed (like cards)
        - played : send to all of the other user what the actual player just played
    - client : 
        - connect : client telling you that is connecting with the server
          needed of later make the starting call and also store some data needed
        - play : send the card played
'''

def random_hand():
    global placeholder_card_list
    result_list = []
    bool_first = False
    for i in range(13):
        t = random.choice(placeholder_card_list)
        if (t == "res://assets/cards/card_diamonds_03.png"): 
            bool_first = True
        placeholder_card_list.remove(t)
        result_list.append(t)
    return result_list, bool_first


async def connect_handler(content, websocket):
    global nb_client
    global connected_client
    global placeholder_card_list
    if nb_client < 4:
        if content["profile_name"] not in connected_client:
            connected_client[content["profile_name"]] = {}

        connected_client[content["profile_name"]]["socket"] = websocket
        connected_client[content["profile_name"]]["card"] = 13 
        nb_client += 1

        result_message = {
            "function": "connected",
            "message": "Connection worked"
        }

        await websocket.send(json.dumps(result_message))
        print("connection from", content["profile_name"])

        if nb_client == 4:
            num = 2
            for client in connected_client:
                list_hand, bool_first = random_hand()
                starting_game_message = {
                    "id" : 1 if bool_first else num,
                    "function": "starting",
                    "message": "game starting",
                    "card_hand": list_hand,
                    "first_player": 1 if bool_first else 0
                }
                connected_client[client]["id"] = 1 if bool_first else num

                if not bool_first:
                    num += 1

                message = json.dumps(starting_game_message)
                await connected_client[client]["socket"].send(message)
            placeholder_card_list = card_list.copy()
    else : 
        await websocket.close(code=999, reason="server is full")

async def broadcast_card(content, websocket):
    global connected_client
    message = {
        "id": content["id"],
        "function": "played",
        "card": content["card"],
    }

    for client in connected_client:
        if (connected_client[client]["id"] != content["id"]):
            await connected_client[client]["socket"].send(json.dumps(message))

async def broadcast_pass(content, websocket):
    global connected_client
    message = {
        "id": content["id"],
        "function": "passed",
    }
    for client in connected_client:
        if (connected_client[client]["id"] != content["id"]):
            await connected_client[client]["socket"].send(json.dumps(message))

async def send_verification(boolean, websocket, message) :
    message = {
        "function": "verification",
        "result": 1 if boolean else 0, 
        "message": message
    }

    await websocket.send(json.dumps(message))

def verification(combi): 
    global last_combi
    if (combi is not None) :
        if (last_combi is not None) : 
            result, message = check_higher_than_previous(last_combi, combi)
            print(result, message)
            return result, message
        else : 
            return True, ""
    else : 
        return False, "This is not a valid combinaison"

async def handler(websocket):
    global nb_client
    global connected_client
    global last_combi

    async for message in websocket:
        content = json.loads(message)
        match content["function"]:
            case "connect":
                await connect_handler(content, websocket)
            case "play": 
                # TODO : Implement verification then broadcast and then tell him you can play
                list_card = get_list_card_info_from_texture(content["card"])
                combi = check_card_clicked(list_card)

                boolean, message = verification(combi)

                if boolean: 
                    await broadcast_card(content, websocket)
                    last_combi = combi
                    connected_client[content["profile_name"]]["card"] -= len(list_card)
                    if (list_card <= 0) :
                        print(content["profile_name"], "won")

                await send_verification(verification, websocket, message)
            case "pass": 
                await broadcast_pass(content, websocket)



async def main():
    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
        await server.serve_forever()

if __name__ == "__main__":
    asyncio.run(main())
