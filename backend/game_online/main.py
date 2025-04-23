import asyncio
import random
import json
import websockets
from websockets.asyncio.server import serve
import ssl
from debut_jeu import get_list_card_info_from_texture
from python_projet import combi_detection, Combinaison, check_higher_than_previous

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(
    certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "0.0.0.0"  # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT = 10006

connected_client = {}
connection_allowed = True

last_combi = Combinaison(None, None, None) 

nb_pass_in_a_row = 0

first_play = True

class Room(): 
    def __init__(self, host_name, room_name, hashed_password): 
        self.host_name = host_name
        self.room_name = room_name
        self.hashed_password = hashed_password

room_holder = {}

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

def generate_all_hand():
    global connected_client
    num = 2
    list_message = {}
    for client in connected_client:
        list_hand, bool_first = random_hand()
        starting_game_message = {
            "id" : 1 if bool_first else num,
            "function": "starting",
            "message": "game starting",
            "card_hand": list_hand,
            "first_player": 1 if bool_first else 0,
            "list_id": {}
        }
        connected_client[client]["id"] = 1 if bool_first else num

        if not bool_first:
            num += 1

        list_message[client] = starting_game_message

    return list_message

def generate_all_id():
    global connected_client
    list_id = {}

    for client in connected_client:
        list_id[client] = connected_client[client]["id"]

    return list_id

async def connect_handler(content, websocket):
    global connected_client
    global placeholder_card_list
    global connection_allowed

    if len(connected_client) < 4 and connection_allowed:
        if content["profile_name"] not in connected_client:
            connected_client[content["profile_name"]] = {}

        connected_client[content["profile_name"]]["socket"] = websocket
        connected_client[content["profile_name"]]["card"] = 13 

        result_message = {
            "function": "connected",
            "message": "Connection worked"
        }

        await websocket.send(json.dumps(result_message))
        print("connection from", content["profile_name"])

        if len(connected_client) == 4:
            list_message = generate_all_hand() 
            list_id = generate_all_id()
            connection_allowed = False
            for client in connected_client:
                list_message[client]["list_id"] = list_id
                await connected_client[client]["socket"].send(json.dumps(list_message[client]))

            placeholder_card_list = card_list.copy()
    else : 
        await websocket.close(code=999, reason="server is full or not available")

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

async def send_verification(boolean, websocket, message, passed) :
    message = {
        "function": "verification",
        "result": 1 if boolean else 0, 
        "message": message,
        "passed" : 1 if passed else 0, 
    }

    await websocket.send(json.dumps(message))

def verification(combi): 
    global last_combi
    if (combi != Combinaison(None, None, None)) :
        if (last_combi != Combinaison(None, None, None)) : 
            result, message = check_higher_than_previous(last_combi, combi)
            print(result, message)
            return result, message
        else : 
            return True, ""
    else : 
        return False, "This is not a valid combinaison"

async def reset_server(reason):
    global connected_client
    global last_combi
    global nb_pass_in_a_row
    global first_play
    global connection_allowed

    await asyncio.sleep(2)
    print("Server is making a reset ...")
    for client in connected_client: 
        await connected_client[client]["socket"].close()

    connected_client = {}
    last_combi = Combinaison(None, None, None)  
    nb_pass_in_a_row = 0
    first_play = True
    connection_allowed = True

async def game_won(winner_username):
    global connected_client

    message = {
        "function" : "game_won",
        "winner" : winner_username
    }

    for client in connected_client:
        await connected_client[client]["socket"].send(json.dumps(message))

    await reset_server("Game finished")

async def create_room(websocket, host_name, room_name, password): 
    global room_holder

    room_holder[room_name] = {
        "host_name": host_name,
        "room_name": room_name,
        "password": password,
        "players": [(host_name, websocket)]
    }

    message = {
        "function" : "room_created",
        "room_name": room_name
    }

    await websocket.send(json.dumps(message))

def get_room(nb): 
    result = []
    for room in room_holder:
        result.append(room)
        nb -= 1
        if nb <= 0: 
            return result

    return result

async def send_room(websocket, nb): 
    list_room = get_room(nb)

    message = {
        "function": "send_room",
        "list_room": list_room
    }

    await websocket.send(json.dumps(message))

async def join_room(websocket, room_name, username): 
    global room_holder

    room_holder[room_name][players].append((websocket, username))
    
    await accept_new_connection(websocket, room_name)
    await broadcast_new_connection(username, room_name)

async def accept_new_connection(websocket, room_name): 
    global room_holder
    players_name = [value for _, value in room_holder[room_name]["players"]]

    message = {
        "function": "room_connected",
        "room_name": room_name,
        "players": players_name 
    }

    await websocket.send(json.dumps(message))

async def accept_new_connection(new_username, room_name):
    global room_holder
    message = json.dumps({
        "function": "new_connection",
        "username": new_username
    })

    for (websocket, username) in room_holder[room_name]["players"]: 
        if username != new_username: 
            websocket.send(message)


async def handler(websocket):
    global connected_client
    global last_combi
    global nb_pass_in_a_row
    global first_play

    try: 
        async for message in websocket:
            content = json.loads(message)
            match content["function"]:
                case "connect":
                    await connect_handler(content, websocket)
                case "play": 
                    list_card = get_list_card_info_from_texture(content["card"])

                    bool_first_play = False
                    if first_play:
                        for card in list_card: 
                            if card.value == 3 and card.form == 1: 
                                bool_first_play = True
                                first_play = False
                    else : 
                        bool_first_play = True

                    if bool_first_play : 
                        combi = combi_detection(list_card)

                        boolean, message = verification(combi)

                        nb_pass_in_a_row = 0 

                        if boolean: 
                            await broadcast_card(content, websocket)
                            last_combi = combi
                            connected_client[content["profile_name"]]["card"] -= len(list_card)
                            if (connected_client[content["profile_name"]]["card"] <= 0) :
                                await game_won(content["profile_name"])

                        await send_verification(boolean, websocket, message, False)
                    else : 
                        await send_verification(False, websocket, "You need to play the 3 of diamond", False)
                case "pass": 
                    if first_play : 
                        await send_verification(False, websocket, "You can't pass for the first move", True)
                    else :
                        nb_pass_in_a_row += 1
                        if (nb_pass_in_a_row >= 3):  
                            last_combi = Combinaison(None, None, None) 
                        await broadcast_pass(content, websocket)
                        await send_verification(True, websocket, "", True) 
                case "leaving":
                    del connected_client[content["profile_name"]]
                    await reset_server("A player left the game")
                case "create_room": 
                    await create_room(content["host_name"], content["room_name"], content["password"])
                case "get_room": 
                    await send_room(5)
                case "join_room": 
                    await join_room(websocket, content["room_name"], content["username"])
    except websockets.exceptions.ConnectionClosed as e:
        for username, data in list(connected_client.items()): 
            if data["socket"] == websocket : 
                del connected_client[username] 
        await reset_server("A player left the game")

async def main():
    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
        await server.serve_forever()

if __name__ == "__main__":
    asyncio.run(main())
