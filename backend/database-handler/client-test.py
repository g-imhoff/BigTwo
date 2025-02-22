#!/usr/bin/env python

from websockets.sync.client import connect

def hello():
    with connect("ws://localhost:18014") as websocket:
        websocket.send("Hello world!")
        message = websocket.recv()
        print(f"Received: {message}")

hello()
