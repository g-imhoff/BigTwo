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
    ("02", "clubs"),
    ("03", "clubs"),
    ("04", "clubs"),
    ("05", "clubs"),
    ("06", "clubs"),
    ("07", "clubs"),
    ("08", "clubs"),
    ("09", "clubs"),
    ("10", "clubs"),
    ("11", "clubs"),
    ("12", "clubs"),
    ("13", "clubs"),
    ("14", "clubs"),
    ("02", "diamonds"),
    ("03", "diamonds"),
    ("04", "diamonds"),
    ("05", "diamonds"),
    ("06", "diamonds"),
    ("07", "diamonds"),
    ("08", "diamonds"),
    ("09", "diamonds"),
    ("10", "diamonds"),
    ("11", "diamonds"),
    ("12", "diamonds"),
    ("13", "diamonds"),
    ("14", "diamonds"),
    ("02", "hearts"),
    ("03", "hearts"),
    ("04", "hearts"),
    ("05", "hearts"),
    ("06", "hearts"),
    ("07", "hearts"),
    ("08", "hearts"),
    ("09", "hearts"),
    ("10", "hearts"),
    ("11", "hearts"),
    ("12", "hearts"),
    ("13", "hearts"),
    ("14", "hearts"),
    ("02", "spades"),
    ("03", "spades"),
    ("04", "spades"),
    ("05", "spades"),
    ("06", "spades"),
    ("07", "spades"),
    ("08", "spades"),
    ("09", "spades"),
    ("10", "spades"),
    ("11", "spades"),
    ("12", "spades"),
    ("13", "spades"),
    ("14", "spades"),
]

placeholder_card_list = card_list.copy()


def random_hand():
    global placeholder_card_list
    result_list = []
    bool_first = False
    for i in range(13):
        t = random.choice(placeholder_card_list)
        if (t[0] == "3" && t[1] == "diamonds"): 
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
            for client in connected_client:
                list_hand, bool_first = random_hand()
                starting_game_message = {
                    "code": 1,
                    "message": "game starting",
                    "card_hand": enumerate(list_hand),
                    "first_player": 1 if bool_first else 0
                }

                message = json.dumps(starting_game_message)
                await connected_client[client].send(message)
            placeholder_card_list = card_list.copy()


async def handler(websocket):
    global nb_client
    global connected_client

    async for message in websocket:
        content = json.loads(message)
        match content["function"]:
            case "connect":
                await connect_handler(content, websocket)


async def main():
    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
        await server.serve_forever()

if __name__ == "__main__":
    random_hand()
    # asyncio.run(main())
