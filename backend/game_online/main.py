# Websockets import
import websockets
from websockets.asyncio.server import serve, ServerConnection

# Basic import
import asyncio
import random
import json
from typing import Any, Dict, List, Tuple, TypedDict
from bdd import increment_game_played, increment_game_won

# Others file import
from debut_jeu import get_list_card_info_from_texture, Card
from python_projet import card_list, combi_detection, Combinaison, check_higher_than_previous

WEBSOCKETS_URL: str = "0.0.0.0"  # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT: int = 10006


class Player:
    def __init__(self, websocket: ServerConnection, username: str, id: int):
        self.websocket: ServerConnection = websocket
        self.username: str = username
        self.id: int = id
        self.card: int = 13


class StartingMessage(TypedDict):
    id: int
    function: str
    message: str
    card_hand: List[str]
    first_player: int
    list_id: Dict[str, int]


class Room:
    def __init__(self, host_name: str, room_name: str,
                 password: str, websocket: ServerConnection,
                 nb_players: int):
        self.host_name: str = host_name
        self.room_name: str = room_name
        self.password: str = password
        self.players: Dict[str, Player] = {
            host_name: Player(websocket, host_name, 0)}
        self.nb_players: int = nb_players
        self.nb_pass_in_a_row: int = 0
        self.first_play: bool = True
        self.last_combi: Combinaison = Combinaison(None, None, None)
        self.placeholder_card_list = card_list.copy()

    async def add_player(self, websocket: ServerConnection,
                         username: str, password: str) -> None:
        if self.nb_players >= 4:
            await Room.failed_new_connection(websocket, "The server is full")
        elif self.password != password:
            await Room.failed_new_connection(websocket, "The password is wrong")
        else:
            self.players[username] = Player(websocket, username, 0)
            self.nb_players += 1
            await self.accept_new_connection(websocket)
            await self.broadcast_new_connection(username)
            increment_game_played(username)

    async def accept_new_connection(self, websocket: ServerConnection) -> None:
        players_name: List[str] = []

        for player in self.players:
            players_name.append(self.players[player].username)

        message: str = json.dumps({
            "function": "room_connected",
            "room_name": self.room_name,
            "host_name": self.host_name,
            "players": players_name
        })

        await websocket.send(message)

    async def broadcast_new_connection(self, new_username: str) -> None:
        players_name: List[str] = []

        for player in self.players:
            players_name.append(self.players[player].username)

        message: str = json.dumps({
            "function": "new_connection",
            "players": players_name
        })

        for player in self.players:
            if self.players[player].username != new_username:
                await self.players[player].websocket.send(message)

    @staticmethod
    async def failed_new_connection(websocket: ServerConnection,
                                    reason: str) -> None:
        message: str = json.dumps({
            "function": "room_connection_failed",
            "reason": reason
        })

        await websocket.send(message)

    async def start_game(self) -> None:
        list_message: dict[str, StartingMessage] = self.generate_all_hand()
        list_id: Dict[str, int] = self.generate_all_id()
        for player in self.players:
            list_message[player]["list_id"] = list_id
            await self.players[player].websocket.send(json.dumps(list_message[player]))

    def generate_all_hand(self) -> dict[str, StartingMessage]:
        num: int = 2
        list_message: dict[str, StartingMessage] = {}
        for player in self.players:
            hand: Tuple[List[str], bool] = self.random_hand()

            starting_game_message: StartingMessage = {
                "id": 1 if hand[1] else num,
                "function": "starting",
                "message": "game starting",
                "card_hand": hand[0],
                "first_player": 1 if hand[1] else 0,
                "list_id": {}
            }

            self.players[player].id = 1 if hand[1] else num

            if not hand[1]:
                num += 1

            list_message[player] = starting_game_message

        return list_message

    def generate_all_id(self) -> Dict[str, int]:
        list_id: Dict[str, int] = {}

        for player in self.players:
            list_id[self.players[player].username] = self.players[player].id

        return list_id

    def random_hand(self) -> Tuple[List[str], bool]:
        result_list: List[str] = []
        bool_first: bool = False
        for _ in range(13):
            t: str = random.choice(self.placeholder_card_list)
            if (t == "res://assets/cards/card_diamonds_03.png"):
                bool_first = True
            self.placeholder_card_list.remove(t)
            result_list.append(t)
        return result_list, bool_first

    async def play_card(self, id: int, username: str,
                        websocket: ServerConnection,
                        list_card_path: List[str]):
        list_card: List[Card] = get_list_card_info_from_texture(list_card_path)

        bool_first_play: bool = False
        if self.first_play:
            for card in list_card:
                if card.value == 3 and card.form == 1:
                    bool_first_play = True
                    self.first_play = False
        else:
            bool_first_play = True

        if bool_first_play:
            combi: Combinaison = combi_detection(list_card)

            result_verif: Tuple[bool, str] = self.verification(combi)

            self.nb_pass_in_a_row = 0

            if result_verif[0]:
                await self.broadcast_card(id, list_card_path)
                self.last_combi = combi
                self.players[username].card -= len(list_card)
                if (self.players[username].card <= 0):
                    await self.game_won(username)
                    increment_game_won(username)

            await Room.send_verification(result_verif[0], websocket, result_verif[1], False)
        else:
            await Room.send_verification(False, websocket, "You need to play the 3 of diamond", False)

    def verification(self, combi: Combinaison) -> Tuple[bool, str]:
        if (combi != Combinaison(None, None, None)):
            if (self.last_combi != Combinaison(None, None, None)):
                result, message = check_higher_than_previous(
                    self.last_combi, combi)
                print(result, message)
                return result, message
            else:
                return True, ""
        else:
            return False, "This is not a valid combinaison"

    async def broadcast_card(self, id: int, card: List[str]) -> None:
        message: str = json.dumps({
            "id": id,
            "function": "played",
            "card": card,
        })

        for player in self.players:
            if (self.players[player].id != id):
                await self.players[player].websocket.send(message)

    async def play_pass(self, id: int, websocket: ServerConnection) -> None:
        if self.first_play:
            await Room.send_verification(False, websocket, "You can't pass for the first move", True)
        else:
            self.nb_pass_in_a_row += 1
            print(self.nb_pass_in_a_row)
            if (self.nb_pass_in_a_row >= 3):
                self.last_combi = Combinaison(None, None, None)
            await self.broadcast_pass(id)
            await Room.send_verification(True, websocket, "", True)

    @staticmethod
    async def send_verification(boolean: bool, websocket: ServerConnection,
                                message_verif: str, passed: bool) -> None:
        message: str = json.dumps({
            "function": "verification",
            "result": 1 if boolean else 0,
            "message": message_verif,
            "passed": 1 if passed else 0,
        })

        await websocket.send(message)

    async def broadcast_pass(self, id: int) -> None:
        message: str = json.dumps({
            "id": id,
            "function": "passed",
        })

        for player in self.players:
            if (self.players[player].id != id):
                await self.players[player].websocket.send(message)

    async def exit_game(self) -> None:
        for player in self.players:
            await self.players[player].websocket.close()

    async def game_won(self, winner_username: str) -> None:
        message: str = json.dumps({
            "function": "game_won",
            "winner": winner_username
        })

        for player in self.players:
            await self.players[player].websocket.send(message)

        await exit(self)


room_holder: Dict[str, Room] = {}


async def create_room(websocket: ServerConnection, host_name: str,
                      room_name: str, password: str) -> None:
    global room_holder

    room: Room = Room(host_name, room_name, password, websocket, 1)

    room_holder[room_name] = room

    await room.accept_new_connection(websocket)


def get_room(nb: int) -> List[Dict[str, str | int]]:
    result: List[Dict[str, str | int]] = []
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


async def send_room(websocket: ServerConnection, nb: int) -> None:
    list_room: List[Dict[str, str | int]] = get_room(nb)

    message: str = json.dumps({
        "function": "send_room",
        "list_room": list_room
    })

    await websocket.send(message)


async def exit(room: Room) -> None:
    global room_holder

    await room.exit_game()
    del room_holder[room.room_name]


async def handler(websocket: ServerConnection):
    global room_holder

    try:
        async for message in websocket:
            content: Dict[str, Any] = json.loads(message)
            print(content)
            match content["function"]:
                case "play":
                    await room_holder[content["room_name"]].play_card(content["id"], content["profile_name"], websocket, content["card"])
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
    except websockets.exceptions.ConnectionClosed as _:
        for room in room_holder:
            for player in room_holder[room].players:
                if room_holder[room].players[player].websocket == websocket:
                    del room_holder[room].players[player]
                    await exit(room_holder[room])


async def main():
    async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT) as server:
        await server.serve_forever()

if __name__ == "__main__":
    asyncio.run(main())
