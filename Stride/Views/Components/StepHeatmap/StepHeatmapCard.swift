//
//  ContributionHeatmapCard.swift
//  Stride
//

import SwiftUI

struct StepHeatmapCard: View {
    let stats: [Date: Int]
    let weeks: Int
    let goal: Int
    let availableWidth: CGFloat

    private let inset: CGFloat = 8
    private let spacing: CGFloat = 2

    init(
        stats: [Date: Int],
        weeks: Int,
        goal: Int,
        availableWidth: CGFloat = UIScreen.main.bounds.width - 32
    ) {
        self.stats = stats
        self.weeks = weeks
        self.goal = goal
        self.availableWidth = availableWidth
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("過去\(weeks)週")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal, 12)

                GeometryReader { proxy in
                    let innerWidth = proxy.size.width - inset * 2
                    let heatmapHeight = StepHeatmap.preferredHeight(for: innerWidth, weeks: weeks, spacing: spacing)
                    let contentWidth = StepHeatmap.preferredContentWidth(for: innerWidth, weeks: weeks, spacing: spacing)

                    StepHeatmap(
                        stats: stats,
                        weeks: weeks,
                        availableWidth: innerWidth,
                        spacing: spacing,
                        goal: goal
                    )
                    .frame(width: contentWidth, height: heatmapHeight, alignment: .topLeading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, inset)
                }
                // tmp: too much margin, substract 30
                .frame(height: StepHeatmap.preferredHeight(for: availableWidth - inset * 2 - 30, weeks: weeks, spacing: spacing))
            }
            .padding(.top, 10)
        }
    }
}
