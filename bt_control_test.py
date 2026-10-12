import asyncio
import sys
from bleak import BleakClient

LED_ADDRESS = "D16769BD-9A8F-D578-8560-A91AB4FDD99A"
EE02_UUID = "0000ee02-0000-1000-8000-00805f9b34fb"
EE01_UUID = "0000ee01-0000-1000-8000-00805f9b34fb" # Attempted to write to this but got "GATT Protocol Error: Write Not Permitted"

# These bytes came from an open-source project, and they worked with my LED device.
COMMANDS = {
    "on": bytes.fromhex("69 96 06 01 01"),
    "off": bytes.fromhex("69 96 02 01 00"),
}


async def main():
    if len(sys.argv) != 2 or sys.argv[1] not in COMMANDS:
        print("Usage: python bt_control_test.py [on|off]")
        return

    action = sys.argv[1]
    command = COMMANDS[action]

    async with BleakClient(LED_ADDRESS, timeout=15.0) as client:
        print(f"[INFO] Connected: {client.is_connected}")
        print(f"[TX] {action.upper()}: {command.hex(' ')}")

        await client.write_gatt_char(
            EE02_UUID,
            command,
            response=True
        )

        print("[INFO] BLE write completed")

    print("[INFO] Disconnected")


asyncio.run(main())