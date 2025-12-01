import WidgetKit
import SwiftUI

struct StrideWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: StepEntry

    var body: some View {
        StepProgressView(
            steps: entry.steps,
            goal: entry.goal,
            emoji: entry.emoji,
            gradientID: entry.gradientID,
            layout: family == .systemMedium ? .medium : .small
        )
    }
}
