import asyncio
from bleak import BleakScanner

async def main():
    devices = await BleakScanner.discover(timeout=10.0)

    for device in device:
        print(f"Name: {device.name}")
        print(f"Adress: {device.address}")
        print("====================================")

asyncio.run(main())
