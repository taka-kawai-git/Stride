import WidgetKit
import SwiftUI

struct StrideWidget: Widget {
    let kind: String = StrideWidgetKind.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepProvider()) { entry in
            StrideWidgetEntryView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Stride Steps")
        .description("Shows your current step count.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    StrideWidget()
} timeline: {
    StepEntry(date: .now, steps: 6_000, emoji: "🏃🏻‍♀️", gradientID: "greenMintBlue", goal: 10_000, lastUpdated: Date())
    StepEntry(date: .now, steps: 9_200, emoji: "🏃🏻‍♀️", gradientID: "pinkPurple",    goal: 12_000, lastUpdated: Date())
}

#Preview(as: .systemMedium) {
    StrideWidget()
} timeline: {
    StepEntry(date: .now, steps: 5_000, emoji: "🏃🏻‍♀️", gradientID: "mono",           goal: 8_000, lastUpdated: Date())
    StepEntry(date: .now, steps: 11_500, emoji: "🏃🏻‍♀️", gradientID: "greenMintBlue", goal: 10_000, lastUpdated: Date())
}
