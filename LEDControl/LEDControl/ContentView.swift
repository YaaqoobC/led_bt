
import SwiftUI

struct ContentView: View {
    @StateObject private var bluetooth = BluetoothManager()

    var body: some View {
        VStack(spacing: 24) {
            Text("LED Control")
                .font(.largeTitle)
                .bold()

            Text(bluetooth.status)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                bluetooth.turnOn()
            } label: {
                Label("Turn On", systemImage: "power")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(!bluetooth.isReady)

            Button {
                bluetooth.turnOff()
            } label: {
                Label("Turn Off", systemImage: "power")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.gray)
            .disabled(!bluetooth.isReady)
        }
        .padding(24)
        .onOpenURL { url in
            guard url.scheme == "ledcontrol",
                  url.host == "power" else {
                return
            }

            switch url.path {
            case "/on":
                bluetooth.requestPower(true)

            case "/off":
                bluetooth.requestPower(false)

            default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
