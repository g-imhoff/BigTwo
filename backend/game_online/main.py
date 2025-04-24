import asyncio
import random
import json
import websockets
from websockets.asyncio.server import serve
import ssl
from debut_jeu import get_list_card_info_from_texture
from python_projet import card_list, combi_detection, Combinaison, check_higher_than_previous
from typing import Dict
from websockets.legacy.server import WebSocketServerProtocol

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(
    certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "0.0.0.0"  # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT = 10006

room_holder = {}

class Player : 
    def __init__(self, websocket: WebSocketServerProtocol, username: str, id: int):
        self.websocket: WebSocketServerProtocol = websocket
        self.username: str = username
        self.id: int = id
        self.card: int = 13

class Room:
    def __init__(self, host_name: str, room_name: str, 
                 password: str, websocket: WebSocketServerProtocol,
                 nb_players: int):
        self.host_name: str = host_name
        self.room_name: str = room_name
        self.password: str = password
        self.players: Dict[str, Player] = {host_name: Player(websocket, host_name, 0)}
        self.nb_players: int = nb_players
        self.nb_pass_in_a_row: int = 0
        self.first_play: bool = True
        self.last_combi: Combinaison = Combinaison(None, None, None)
        self.placeholder_card_list = card_list.copy()

    async def add_player(self, websocket, username, password): 
        if self.nb_players >= 4:
            await Room.failed_new_connection(websocket, "The server is full")
        elif self.password != password: 
            await Room.failed_new_connection(websocket, "The password is wrong")
        else : 
            self.players[username] = Player(websocket, username, 0)
            self.nb_players += 1

        await self.accept_new_connection(websocket)
        await self.broadcast_new_connection(username)

    async def accept_new_connection(self, websocket): 
        players_name = []
        
        for player in self.players:
            players_name.append(self.players[player].username)

        message = {
            "function": "room_connected",
            "room_name": self.room_name,
            "host_name": self.host_name,
            "players": players_name 
        }

        await websocket.send(json.dumps(message))

    async def broadcast_new_connection(self, new_username):
        players_name = []
        
        for player in self.players:
            players_name.append(self.players[player].username)

        message = json.dumps({
            "function": "new_connection",
            "players":  players_name
        })

        for player in self.players: 
            if self.players[player].username != new_username: 
                await self.players[player].websocket.send(message)

    @staticmethod
    async def failed_new_connection(websocket, reason): 
        message = {
            "function": "room_connection_failed",
            "reason": reason
        }

        await websocket.send(json.dumps(message))

    async def start_game(self): 
        list_message = self.generate_all_hand() 
        list_id = self.generate_all_id()
        for player in self.players:
            list_message[player]["list_id"] = list_id
            await self.players[player].websocket.send(json.dumps(list_message[player]))

    def generate_all_hand(self):
        num = 2
        list_message = {}
        for player in self.players:
            list_hand, bool_first = self.random_hand()
            starting_game_message = {
                "id" : 1 if bool_first else num,
                "function": "starting",
                "message": "game starting",
                "card_hand": list_hand,
                "first_player": 1 if bool_first else 0,
                "list_id": {}
            }

            self.players[player].id = 1 if bool_first else num

            if not bool_first:
                num += 1

            list_message[player] = starting_game_message

        return list_message

    def generate_all_id(self): 
        list_id = {}

        for player in self.players: 
            list_id[self.players[player].username] = self.players[player].id 

        return list_id

    def random_hand(self):
        result_list = []
        bool_first = False
        for i in range(13):
            t = random.choice(self.placeholder_card_list)
            if (t == "res://assets/cards/card_diamonds_03.png"): 
                bool_first = True
            self.placeholder_card_list.remove(t)
            result_list.append(t)
        return result_list, bool_first

    async def play_card(self, id, room_name, username, websocket, card_list): 
        list_card = get_list_card_info_from_texture(card_list)

        bool_first_play = False
        if self.first_play:
            for card in list_card: 
                if card.value == 3 and card.form == 1: 
                    bool_first_play = True
                    self.first_play = False
        else : 
            bool_first_play = True

        if bool_first_play : 
            combi = combi_detection(list_card)

            boolean, message = self.verification(combi)

            self.nb_pass_in_a_row = 0 

            if boolean: 
                await self.broadcast_card(id, card_list, websocket)
                self.last_combi = combi
                self.players[username].card -= len(list_card)
                if (self.players[username].card <= 0) :
                    await self.game_won(username)

            await Room.send_verification(boolean, websocket, message, False)
        else : 
            await Room.send_verification(False, websocket, "You need to play the 3 of diamond", False)

    def verification(self, combi): 
        if (combi != Combinaison(None, None, None)) :
            if (self.last_combi != Combinaison(None, None, None)) : 
                result, message = check_higher_than_previous(self.last_combi, combi)
                print(result, message)
                return result, message
            else : 
                return True, ""
        else : 
            return False, "This is not a valid combinaison"

    async def broadcast_card(self, id, card, websocket):
        message = {
            "id": id,
            "function": "played",
            "card": card,
        }

        for player in self.players:
            if (self.players[player].id != id):
                await self.players[player].websocket.send(json.dumps(message))

    async def play_pass(self, id, websocket): 
        if self.first_play : 
            await Room.send_verification(False, websocket, "You can't pass for the first move", True)
        else :
            self.nb_pass_in_a_row += 1
            if (self.nb_pass_in_a_row >= 3):  
                self.last_combi = Combinaison(None, None, None) 
            await self.broadcast_pass(id, websocket)
            await Room.send_verification(True, websocket, "", True) 

    @staticmethod
    async def send_verification(boolean, websocket, message, passed) :
        message = {
            "function": "verification",
            "result": 1 if boolean else 0, 
            "message": message,
            "passed" : 1 if passed else 0, 
        }

        await websocket.send(json.dumps(message))

    async def broadcast_pass(self, id, websocket):
        message = {
            "id": id,
            "function": "passed",
        }

        for player in self.players:
            if (self.players[player].id != id):
                await self.players[player].websocket.send(json.dumps(message))

    async def exit_game(self): 
        for player in self.players:
            self.players[player].websocket.close()

    async def game_won(self, winner_username):
        message = json.dumps({
            "function" : "game_won",
            "winner" : winner_username
        })

        for player in self.players:
            await self.players[player].websocket.send(message)

        exit(self)

async def create_room(websocket, host_name, room_name, password): 
    global room_holder

    room: Room = Room(host_name, room_name, password, websocket, 1)

    room_holder[room_name] = room

    await room.accept_new_connection(websocket)

def get_room(nb): 
    result = []
    for room in room_holder:
        if room_holder[room].nb_players < 4: 
            message = {
                "room_name": room_holder[room].room_name, 
                "players": len(room_holder[room].players)
            }

            result.append(message)

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

async def exit(room: Room):
    global room_holder

    await room.exit_game()
    del room

async def handler(websocket):
    global room_holder

    try: 
        async for message in websocket:
            content = json.loads(message)
            match content["function"]:
                case "play": 
                    await room_holder[content["room_name"]].play_card(content["id"], content["room_name"], content["profile_name"], websocket, content["card"])
                case "pass": 
                    await room_holder[content["room_name"]].play_pass(content["id"], websocket)
                case "leaving":
                    await exit(room_holder[content["room_name"]])
                case "create_room": 
                    await create_room(websocket, content["host_name"], content["room_name"], content["password"])
                case "get_room": 
                    await send_room(websocket, 5)
                case "join_room": 
                    await room_holder[content["room_name"]].add_player(websocket, content["username"], content["password"])
                case "start_game": 
                    await room_holder[content["room_name"]].start_game()
    except websockets.exceptions.ConnectionClosed as e:
        for room in room_holder: 
            for player in room_holder[room].players:
                if player.websocket == websocket: 
                    room_holder[room].players.remove(player)
                    await exit(room_holder[room])

async def main():
    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
        await server.serve_forever()

if __name__ == "__main__":
    asyncio.run(main())
