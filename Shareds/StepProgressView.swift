import SwiftUI

/// Shared UI component that mirrors the widget's progress presentation.
struct StepProgressView: View {
    enum LayoutStyle {
        case small
        case medium
    }

    var steps: Int
    var goal: Int = 10_000
    var emoji: String = "🥾"
    var gradientID: String = "greenMintBlue"
    var layout: LayoutStyle = .small
    var emojiFont: Font?
    var stepsFont: Font?
    var stepUnitFont: Font?
    var goalFont: Font?
    var progressLabelFont: Font?

    private var progress: CGFloat {
        guard goal > 0 else { return 0 }
        return min(CGFloat(steps) / CGFloat(goal), 1)
    }

    private var progressPercentage: String {
        String(format: "%.0f%%", progress * 100)
    }
    
    // ================ Body ================

    var body: some View {
        switch layout {
        case .medium:
            mediumLayout
        case .small:
            smallLayout
        }
    }
    
    // ================ UI ================

    private var smallLayout: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
            header(
                emojiFont: emojiFont ?? .largeTitle,
                numberFont: stepsFont ?? .title2,
                unitFont: stepUnitFont ?? .footnote,
                goalFont: goalFont ?? .caption2,
                weight: .bold,
                spacing: 5
            )
            progressBar(height: 25)
        }
        .padding(.vertical, 8)
        }
    }

    private var mediumLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            header(
                emojiFont: emojiFont ?? .system(size: 40),
                numberFont: stepsFont ?? .largeTitle,
                unitFont: stepUnitFont ?? .subheadline,
                goalFont: goalFont ?? .caption2,
                weight: .bold,
                spacing: 12,
                progressNumber: progressPercentage
            )

            progressBar(height: 25)
        }
         .padding(12)
    }

    private func header(
        emojiFont: Font,
        numberFont: Font,
        unitFont: Font,
        goalFont: Font,
        weight: Font.Weight,
        spacing: CGFloat,
        progressNumber: String? = nil
    ) -> some View {
        HStack(spacing: spacing) {
            Text(emoji)
                .font(emojiFont)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(steps)")
                        .font(numberFont)
                        .fontWeight(weight)
                    Text("歩")
                        .font(unitFont)
                        .fontWeight(weight)
                    if let progressNumber {
                        progressBadge(text: progressNumber)
                            .padding(.leading, 15)
                    }
                }
                Text("目標 \(goal.formatted())歩")
                    .font(goalFont)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func progressBadge(text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
            )
    }

    private func progressBar(height: CGFloat) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                Capsule()
                    .fill(gradient(for: gradientID))
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: height)
    }
}
