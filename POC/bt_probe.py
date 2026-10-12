import asyncio
from bleak import BleakClient

LED_ADDRESS = "D16769BD-9A8F-D578-8560-A91AB4FDD99A"

EE01_UUID = "0000ee01-0000-1000-8000-00805f9b34fb"
EE02_UUID = "0000ee02-0000-1000-8000-00805f9b34fb"


async def main():
    async with BleakClient(LED_ADDRESS, timeout=15.0) as client:
        print(f"[INFO] Connected: {client.is_connected}")

        for uuid in [EE01_UUID, EE02_UUID]:
            data = await client.read_gatt_char(uuid)

            print(f"\n[READ] {uuid}")
            print(f"  HEX: {data.hex(' ')}")
            print(f"  Length: {len(data)} bytes")

        # Inspect the descriptors associated with each characteristic
        print("\n[INFO] GATT descriptors:")

        for service in client.services:
            for characteristic in service.characteristics:
                print(f"\nCharacteristic: {characteristic.uuid}")

                if not characteristic.descriptors:
                    print("  No descriptors discovered")

                for descriptor in characteristic.descriptors:
                    print(f"  Descriptor: {descriptor.uuid}")

    print("\n[INFO] Disconnected")


asyncio.run(main())