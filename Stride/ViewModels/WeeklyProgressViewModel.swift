import Foundation

@MainActor
final class WeeklyProgressViewModel: ObservableObject {
    struct WeeklyProgress {
        let totalSteps: Int
        let targetSteps: Int
        let activeDays: Int
        static let empty = WeeklyProgress(totalSteps: 0, targetSteps: 0, activeDays: 1)

        var progress: Double {
            guard targetSteps > 0 else { return 0 }
            return Double(totalSteps) / Double(targetSteps)
        }

        var clampedProgress: Double {
            min(max(progress, 0), 1)
        }
    }

    private let calendar: Calendar
    @Published var weeklyProgress: WeeklyProgress = .empty

    init(calendar: Calendar? = nil) {
        self.calendar = calendar ?? Self.makeMondayStartingCalendar()
    }

    func update(
        dailyCounts: [Date: Int],
        goal: Int,
        today: Date = Date()
    ) {
        weeklyProgress = progressThisWeek(
            dailyCounts: dailyCounts,
            goal: goal,
            today: today
        )
    }

    func progressThisWeek(
        dailyCounts: [Date: Int],
        goal: Int,
        today: Date = Date()
    ) -> WeeklyProgress {
        let weekStart = startOfWeek(for: today)
        let activeDays = clampedDayCount(from: weekStart, to: today)
        let totalSteps = sumSteps(dailyCounts, start: weekStart, days: activeDays)
        let targetSteps = goal * 7

        return WeeklyProgress(
            totalSteps: totalSteps,
            targetSteps: targetSteps,
            activeDays: activeDays
        )
    }

    private func startOfWeek(for date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        return calendar.dateInterval(of: .weekOfYear, for: startOfDay)?.start ?? startOfDay
    }

    private func clampedDayCount(from weekStart: Date, to today: Date) -> Int {
        let startOfToday = calendar.startOfDay(for: today)
        let dayOffset = calendar.dateComponents([.day], from: weekStart, to: startOfToday).day ?? 0
        return max(1, min(dayOffset + 1, 7))
    }

    private func sumSteps(_ dailyCounts: [Date: Int], start: Date, days: Int) -> Int {
        guard days > 0 else { return 0 }

        var total = 0
        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { continue }
            let dayKey = calendar.startOfDay(for: date)
            total += dailyCounts[dayKey] ?? 0
        }
        return total
    }

    private static func makeMondayStartingCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }
}
