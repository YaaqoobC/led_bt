import asyncio
from bleak import BleakScanner

async def main():
    print("Starting Bluetooth Scan for Devices...")
    devices = await BleakScanner.discover(timeout=10.0)
    devices = await BleakScanner.discover(
            timeout = 15.0,
            return_adv = True
    )

    for address, (device, adv) in devices.items():
        print(f"Name: {adv.local_name or device.name or 'Unknown'}")
        print(f"Address: {address}")
        print(f"RSSI: {adv.rssi} dBm")
        print(f"Services: {adv.service_uuids}")
        print("====================================")

asyncio.run(main())
