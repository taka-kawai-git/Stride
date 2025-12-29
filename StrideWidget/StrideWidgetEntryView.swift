import WidgetKit
import SwiftUI

struct StrideWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: StepEntry

    var body: some View {
        contentView
    }

    @ViewBuilder
    private var contentView: some View {
        if family == .systemMedium {
            VStack(alignment: .leading, spacing: 0){
                Text("Today")
                    .font(.subheadline)
                    .bold()
                StepProgressViewMedium(
                    steps: entry.steps,
                    goal: entry.goal,
                    emoji: entry.emoji,
                    gradientID: entry.gradientID
                )
            }
            .padding(.horizontal,5)
        } else {
            VStack(alignment: .leading, spacing: 0){
                Text("Today")
                    .font(.subheadline)
                    .bold()
                StepProgressViewSmall(
                    steps: entry.steps,
                    goal: entry.goal,
                    emoji: entry.emoji,
                    gradientID: entry.gradientID
                )
            }
        }
    }
}
