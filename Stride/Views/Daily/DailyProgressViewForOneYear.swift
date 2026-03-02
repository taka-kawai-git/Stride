//
//  DailyProgressViewForOneYear.swift
//  Stride
//

import SwiftUI

struct DailyProgressViewForOneYear: View {
    let stats: [Date: Int]
    let goal: Int
    let totalWeeks: Int

    private let weeksPerSegment: Int = 13

    private var segmentCount: Int {
        max(1, Int(ceil(Double(totalWeeks) / Double(weeksPerSegment))))
    }

    private var segmentEndDates: [Date] {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        return (0..<segmentCount).map { index in
            calendar.date(byAdding: .day, value: -(index * weeksPerSegment * 7), to: today)!
        }
    }

    init(stats: [Date: Int], goal: Int, totalWeeks: Int = 12) {
        self.stats = stats
        self.goal = goal
        self.totalWeeks = totalWeeks
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(Array(segmentEndDates.enumerated()), id: \.offset) { index, endDate in
                    let remainingWeeks = totalWeeks - index * weeksPerSegment
                    StepHeatmapCard(
                        stats: stats,
                        weeks: min(weeksPerSegment, remainingWeeks),
                        goal: goal,
                        endDate: endDate
                    )
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical)
        }
        .navigationTitle(totalWeeks >= 52 ? "過去1年" : String(format: String(localized: "過去%lld週"), totalWeeks))
        .navigationBarTitleDisplayMode(.inline)
    }
}
