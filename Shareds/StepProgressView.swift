import SwiftUI

private let smallNumberFont = Font.custom("AvenirNext-Bold", size: 28)
private let mediumNumberFont = Font.custom("AvenirNext-Bold", size: 34)
private let mediumBadgeNumberFont = Font.custom("AvenirNext-Bold", size: 12)

private func stepProgressRate(steps: Int, goal: Int) -> CGFloat {
    guard goal > 0 else { return 0 }
    return min(CGFloat(steps) / CGFloat(goal), 1)
}

private func stepProgressPercentageText(rate: CGFloat) -> String {
    String(format: "%.0f%%", rate * 100)
}

// MARK: - Small

struct StepProgressViewSmall: View {
    var steps: Int
    var goal: Int = 10_000
    var emoji: String = "🥾"
    var gradientID: String = "greenMintBlue"

    private var progress: CGFloat { stepProgressRate(steps: steps, goal: goal) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                // Text(emoji)
                //     .font(.largeTitle)

                VStack(alignment: .leading, spacing: -2) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(steps)")
                            .font(smallNumberFont)
                            .fontWeight(.bold)
                        Text("歩")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }

                    Text("目標 \(goal.formatted())歩")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                    Capsule()
                        .fill(gradient(for: gradientID))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 25)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Medium

struct StepProgressViewMedium: View {
    var steps: Int
    var goal: Int = 10_000
    var emoji: String = "🥾"
    var gradientID: String = "greenMintBlue"

    private var progress: CGFloat { stepProgressRate(steps: steps, goal: goal) }
    private var progressPercentage: String { stepProgressPercentageText(rate: progress) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: -3) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(steps)")
                            .font(mediumNumberFont)
                            .fontWeight(.bold)
                        Text("歩")
                            .font(.caption)
                            .fontWeight(.bold)
                        progressBadge(text: progressPercentage)
                            .padding(.leading, 15)
                            .offset(y: -5)                    }

                    Text("目標 \(goal.formatted())歩")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                    Capsule()
                        .fill(gradient(for: gradientID))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 25)
        }
        .padding(.vertical, 8)
    }

    private func progressBadge(text: String) -> some View {
        Text(text)
            .font(mediumBadgeNumberFont)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
            )
    }
}
