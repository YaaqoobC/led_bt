
import Foundation
import CoreBluetooth
import Combine

final class BluetoothManager: NSObject, ObservableObject {

    // MARK: - UI State

    @Published var status = "Starting Bluetooth..."
    @Published var isReady = false

    // MARK: - Bluetooth Properties

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?

    private let deviceName = "BJ_LED_M"
    private let serviceUUID = CBUUID(string: "EEA0")
    private let characteristicUUID = CBUUID(string: "EE02")

    // Stores the latest ON/OFF request while connecting.
    private var pendingPower: Bool?

    // MARK: - Initialization

    override init() {
        super.init()

        central = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

    // MARK: - LED Commands

    func turnOn() {
        send([0x69, 0x96, 0x06, 0x01, 0x01])
    }

    func turnOff() {
        send([0x69, 0x96, 0x02, 0x01, 0x00])
    }

    // Can be called before the BLE connection is ready.
    // Useful for commands received from a widget/deep link.
    func requestPower(_ on: Bool) {
        if isReady {
            if on {
                turnOn()
            } else {
                turnOff()
            }
        } else {
            pendingPower = on
            status = "Waiting for LED connection..."

            if central.state == .poweredOn,
               peripheral == nil,
               !central.isScanning {
                startScanning()
            }
        }
    }

    private func send(_ bytes: [UInt8]) {
        guard let peripheral,
              let commandCharacteristic,
              isReady else {
            status = "LED controller not connected"
            return
        }

        peripheral.writeValue(
            Data(bytes),
            for: commandCharacteristic,
            type: .withResponse
        )

        status = "Sending command..."
    }

    private func flushPendingCommand() {
        guard isReady, let on = pendingPower else {
            return
        }

        pendingPower = nil

        if on {
            turnOn()
        } else {
            turnOff()
        }
    }

    // MARK: - Connection Helpers

    private func startScanning() {
        guard central.state == .poweredOn else {
            return
        }

        guard !central.isScanning else {
            return
        }

        status = "Searching for \(deviceName)..."

        central.scanForPeripherals(
            withServices: nil,
            options: nil
        )
    }

    private func resetConnection() {
        peripheral = nil
        commandCharacteristic = nil
        isReady = false
    }
}

// MARK: - Central Manager Delegate

extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {

        case .poweredOn:
            startScanning()

        case .poweredOff:
            resetConnection()
            status = "Bluetooth is turned off"

        case .unauthorized:
            resetConnection()
            status = "Bluetooth permission denied"

        case .unsupported:
            resetConnection()
            status = "Bluetooth not supported"

        case .resetting:
            resetConnection()
            status = "Bluetooth resetting..."

        case .unknown:
            resetConnection()
            status = "Bluetooth initializing..."

        @unknown default:
            resetConnection()
            status = "Unknown Bluetooth state"
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover device: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let advertisedName =
            advertisementData[CBAdvertisementDataLocalNameKey] as? String

        let name = (
            advertisedName ?? device.name ?? ""
        ).trimmingCharacters(in: .whitespacesAndNewlines)

        guard name == deviceName else {
            return
        }

        central.stopScan()

        peripheral = device
        device.delegate = self

        status = "Connecting to \(deviceName)..."

        central.connect(device, options: nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        status = "Discovering LED service..."

        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        resetConnection()

        status = "Connection failed. Retrying..."

        startScanning()
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        resetConnection()

        status = "Disconnected. Reconnecting..."

        startScanning()
    }
}

// MARK: - Peripheral Delegate

extension BluetoothManager: CBPeripheralDelegate {

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        guard error == nil,
              let service = peripheral.services?.first(
                where: { $0.uuid == serviceUUID }
              ) else {
            status = "LED service not found"
            return
        }

        status = "Discovering command characteristic..."

        peripheral.discoverCharacteristics(
            [characteristicUUID],
            for: service
        )
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard error == nil,
              let characteristic = service.characteristics?.first(
                where: { $0.uuid == characteristicUUID }
              ),
              characteristic.properties.contains(.write) else {
            status = "Writable characteristic not found"
            return
        }

        commandCharacteristic = characteristic
        isReady = true

        status = "Connected to \(deviceName)"

        // Send any ON/OFF command queued during connection.
        flushPendingCommand()
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            status = "Write failed: \(error.localizedDescription)"
        } else {
            status = "Command sent successfully"
        }
    }
}
