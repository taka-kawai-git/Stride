import Foundation
import CoreGraphics

extension StepHeatmap {
    struct LayoutMetrics {
        let cellSize: CGFloat
        let contentWidth: CGFloat
        let gridHeight: CGFloat

        var totalHeight: CGFloat {
            gridHeight + StepHeatmap.labelRowHeight + StepHeatmap.labelSpacing
        }
    }

    struct MonthLabelEntry: Identifiable {
        let id = UUID()
        let text: String
        let offset: CGFloat
    }

    struct HeatmapData {
        let columns: [[Date]]
        let layout: LayoutMetrics
        let labelEntries: [MonthLabelEntry]
    }

    static func makeHeatmapData(weeks: Int, width: CGFloat, spacing: CGFloat) -> HeatmapData {
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: today)!
        let days = dateRange(from: start, to: today)
        let columns = groupByWeek(days)
        let layout = layout(for: width, columnCount: columns.count, spacing: spacing)
        let entries = monthLabelEntries(for: columns, cellWidth: layout.cellSize, spacing: spacing)

        return HeatmapData(columns: columns, layout: layout, labelEntries: entries)
    }

    static func preferredHeight(for width: CGFloat, weeks: Int, spacing: CGFloat = 2) -> CGFloat {
        let columnCount = columnCount(for: weeks)
        return layout(for: width, columnCount: columnCount, spacing: spacing).totalHeight
    }

    static func preferredContentWidth(for width: CGFloat, weeks: Int, spacing: CGFloat = 2) -> CGFloat {
        let columnCount = columnCount(for: weeks)
        return layout(for: width, columnCount: columnCount, spacing: spacing).contentWidth
    }

    static func cellDate(forWeek week: [Date], weekday: Int) -> Date? {
        week.first { calendar.component(.weekday, from: $0) - 1 == weekday }
    }

    private static func layout(for width: CGFloat, columnCount: Int, spacing: CGFloat) -> LayoutMetrics {
        let columns = max(CGFloat(columnCount), 1)
        let safeWidth = max(width, 0)
        let labelAreaWidth = StepHeatmap.weekdayLabelWidth + spacing
        let totalSpacing = max(columns - 1, 0) * spacing
        let gridAvailableWidth = max(safeWidth - labelAreaWidth, 0)
        let usableWidth = max(gridAvailableWidth - totalSpacing, 0)
        let cell = columns > 0 ? floor(usableWidth / columns) : 0
        let cellSize = max(cell, 0)
        let gridWidth = columns * cellSize + totalSpacing
        let contentWidth = labelAreaWidth + gridWidth
        let gridHeight = 7 * cellSize + 6 * spacing
        return LayoutMetrics(cellSize: cellSize, contentWidth: contentWidth, gridHeight: gridHeight)
    }

    private static func columnCount(for weeks: Int) -> Int {
        let today = calendar.startOfDay(for: Date())
        let clampedWeeks = max(weeks, 1)
        guard let start = calendar.date(byAdding: .day, value: -(clampedWeeks * 7 - 1), to: today) else {
            return clampedWeeks
        }
        let days = dateRange(from: start, to: today)
        let columns = groupByWeek(days)
        return max(columns.count, 1)
    }

    private static func dateRange(from start: Date, to end: Date) -> [Date] {
        var arr: [Date] = []
        var current = start
        while current <= end {
            arr.append(calendar.startOfDay(for: current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return arr
    }

    private static func groupByWeek(_ days: [Date]) -> [[Date]] {
        guard let firstDay = days.first else { return [] }
        var weeks: [[Date]] = []
        var bucket: [Date] = []
        var currentWeek = calendar.component(.weekOfYear, from: firstDay)

        for day in days {
            let week = calendar.component(.weekOfYear, from: day)
            if week != currentWeek {
                weeks.append(bucket)
                bucket.removeAll(keepingCapacity: true)
                currentWeek = week
            }
            bucket.append(day)
        }

        if !bucket.isEmpty {
            weeks.append(bucket)
        }
        return weeks
    }

    private static func monthLabelEntries(for columns: [[Date]], cellWidth: CGFloat, spacing: CGFloat) -> [MonthLabelEntry] {
        var entries: [MonthLabelEntry] = []
        var previousMonth: Int?

        for (index, week) in columns.enumerated() {
            guard let date = week.first else { continue }
            let currentMonth = calendar.component(.month, from: date)
            guard currentMonth != previousMonth else { continue }
            previousMonth = currentMonth

            let text = monthFormatter.string(from: date)
            let offset = CGFloat(index) * (cellWidth + spacing)
            entries.append(MonthLabelEntry(text: text, offset: offset))
        }

        return entries
    }
}
