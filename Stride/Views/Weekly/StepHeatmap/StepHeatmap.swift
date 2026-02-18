import SwiftUI
import Foundation

struct StepHeatmap: View {
    let stats: [Date: Int]
    let weeks: Int
    let availableWidth: CGFloat
    let spacing: CGFloat
    let goal: Int
    @Binding var selectedDate: Date?

    static let calendar = Calendar(identifier: .gregorian)
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter
    }()
    static let labelRowHeight: CGFloat = 18
    static let labelSpacing: CGFloat = 4
    static let weekdayLabelWidth: CGFloat = 18
    static let weekdaySymbols: [String] = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.veryShortWeekdaySymbols ?? formatter.shortWeekdaySymbols ?? []
        if symbols.count == 7 {
            return symbols
        }
        return ["日","月","火","水","木","金","土"]
    }()

    init(
        stats: [Date: Int],
        weeks: Int = 12,
        availableWidth: CGFloat,
        spacing: CGFloat = 2,
        goal: Int,
        selectedDate: Binding<Date?>
    ) {
        self.stats = stats
        self.weeks = weeks
        self.availableWidth = availableWidth
        self.spacing = spacing
        self.goal = goal
        self._selectedDate = selectedDate
    }

    var body: some View {
        let data = Self.makeHeatmapData(weeks: weeks, width: availableWidth, spacing: spacing)
        let leadingOffset = Self.weekdayLabelWidth + spacing

        ZStack(alignment: .topLeading) {
            MonthLabels(entries: data.labelEntries, leadingOffset: leadingOffset)
            HeatmapGrid(
                columns: data.columns,
                stats: stats,
                cellSize: data.layout.cellSize,
                spacing: spacing,
                maxValue: goal,
                selectedDate: $selectedDate
            )
            .padding(.top, Self.labelRowHeight + Self.labelSpacing)
        }
        .frame(width: data.layout.contentWidth, height: data.layout.totalHeight, alignment: .topLeading)
        .accessibilityLabel(Text("活動ヒートマップ"))
    }

}
