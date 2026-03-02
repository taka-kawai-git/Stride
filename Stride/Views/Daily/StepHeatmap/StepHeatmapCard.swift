//
//  ContributionHeatmapCard.swift
//  Stride
//

import SwiftUI

struct StepHeatmapCard: View {
    let stats: [Date: Int]
    let weeks: Int
    let goal: Int
    let endDate: Date?
    let availableWidth: CGFloat

    @State private var selectedDate: Date?

    private let inset: CGFloat = 8
    private let spacing: CGFloat = 2

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "M/d（E）"
        return f
    }()

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("yyyy/M")
        return f
    }()

    init(
        stats: [Date: Int],
        weeks: Int,
        goal: Int,
        endDate: Date? = nil,
        availableWidth: CGFloat = UIScreen.main.bounds.width - 32
    ) {
        self.stats = stats
        self.weeks = weeks
        self.goal = goal
        self.endDate = endDate
        self.availableWidth = availableWidth
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                if let date = selectedDate, let steps = stats[date] {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Self.dateFormatter.string(from: date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: String(localized: "%@歩"), steps.formatted()))
                            .font(.system(size: 22, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                } else {
                    Text(headerTitle)
                        .font(.system(size: 22, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                }

                GeometryReader { proxy in
                    let innerWidth = proxy.size.width - inset * 2
                    let heatmapHeight = StepHeatmap.preferredHeight(for: innerWidth, weeks: weeks, spacing: spacing, endDate: endDate)
                    let contentWidth = StepHeatmap.preferredContentWidth(for: innerWidth, weeks: weeks, spacing: spacing, endDate: endDate)

                    StepHeatmap(
                        stats: stats,
                        weeks: weeks,
                        availableWidth: innerWidth,
                        spacing: spacing,
                        goal: goal,
                        endDate: endDate,
                        selectedDate: $selectedDate
                    )
                    .frame(width: contentWidth, height: heatmapHeight, alignment: .topLeading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, inset)
                }
                // tmp: too much margin, substract 30
                .frame(height: StepHeatmap.preferredHeight(for: availableWidth - inset * 2 - 30, weeks: weeks, spacing: spacing, endDate: endDate))
            }
            .padding(.top, 10)
            .padding(.bottom, 6)
        }
    }

    private var headerTitle: String {
        guard let end = endDate else {
            return String(format: String(localized: "過去%lld週"), weeks)
        }
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: end)!
        let startStr = Self.monthYearFormatter.string(from: start)
        let endStr = Self.monthYearFormatter.string(from: end)
        if startStr == endStr {
            return startStr
        }
        return "\(startStr) - \(endStr)"
    }
}
