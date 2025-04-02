import asyncio
import random
import json
from websockets.asyncio.server import serve
import ssl

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(
    certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "0.0.0.0"  # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT = 10006

connected_client = {}
nb_client = 0

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
        connected_client[content["profile_name"]] = websocket
        nb_client += 1

        result_message = {
            "code": 0,
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
                    "code": 1,
                    "message": "game starting",
                    "card_hand": list_hand,
                    "first_player": 1 if bool_first else 0
                }

                if not bool_first:
                    num += 1

            message = json.dumps(starting_game_message)
            await connected_client[client].send(message)
            placeholder_card_list = card_list.copy()
    else : 
        websocket.close(code=999, reason="server is full")


async def handler(websocket):
    global nb_client
    global connected_client

    async for message in websocket:
        content = json.loads(message)
        print(content)
        match content["function"]:
            case "connect":
                await connect_handler(content, websocket)


async def main():
    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
        await server.serve_forever()

if __name__ == "__main__":
    asyncio.run(main())
