import asyncio
from websockets.asyncio.server import serve
import ssl

ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.minimum_version = ssl.TLSVersion.TLSv1_2
ssl_context.load_cert_chain(
    certfile="../certs/cert.pem", keyfile="../certs/key.pem")

WEBSOCKETS_URL = "localhost" # for the moment, turn to 0.0.0.0 after
WEBSOCKETS_PORT = 10006

async def handler(websocket):
  async for message in websocket:
    print(message)


async def main():
  async with serve(handler, WEBSOCKETS_URL, WEBSOCKETS_PORT, ssl=ssl_context) as server:
    await server.serve_forever()

if __name__ == "__main__":
  asyncio.run(main())
