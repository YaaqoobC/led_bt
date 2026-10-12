# Script used to connection and service discovery

import asyncio
from bleak import BleakClient

LED_ADDRESS = "D16769BD-9A8F-D578-8560-A91AB4FDD99A"

async def main():
    print("[INFO] Connecting to BJ_LED_M...")

    async with BleakClient(LED_ADDRESS, timeout=15.0) as client:
        print(f"[INFO] Connected: {client.is_connected}")

        for service in client.services:
            print(f"\nService: {service.uuid}")
            print(f"Description: {service.description}")

            for characteristic in service.characteristics:
                print(f"  Characteristic: {characteristic.uuid}")
                print(f"  Properties: {characteristic.properties}")

    print("\n[INFO] Disconnected.")

asyncio.run(main())