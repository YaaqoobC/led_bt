
import SwiftUI
import WidgetKit

// MARK: - Timeline Data

struct LEDEntry: TimelineEntry {
    let date: Date
}

// MARK: - Timeline Provider

struct LEDProvider: TimelineProvider {

    func placeholder(in context: Context) -> LEDEntry {
        LEDEntry(date: Date())
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (LEDEntry) -> Void
    ) {
        completion(LEDEntry(date: Date()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<LEDEntry>) -> Void
    ) {
        let entry = LEDEntry(date: Date())

        completion(
            Timeline(entries: [entry], policy: .never)
        )
    }
}

// MARK: - Widget Interface

struct LEDWidgetView: View {
    let entry: LEDEntry

    var body: some View {
        VStack(spacing: 12) {

            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.cyan)

                Text("LED Control")
                    .font(.headline)

                Spacer()
            }

            HStack(spacing: 12) {

                Link(destination: URL(
                    string: "ledcontrol://power/on"
                )!) {
                    Label("ON", systemImage: "power")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(
                            .green,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }

                Link(destination: URL(
                    string: "ledcontrol://power/off"
                )!) {
                    Label("OFF", systemImage: "power")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(
                            .gray,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget Configuration

struct LEDControlWidget: Widget {
    let kind = "LEDControlWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: LEDProvider()
        ) { entry in
            LEDWidgetView(entry: entry)
        }
        .configurationDisplayName("LED Control")
        .description("Turn your LED lights on or off.")
        .supportedFamilies([.systemMedium])
    }
}
