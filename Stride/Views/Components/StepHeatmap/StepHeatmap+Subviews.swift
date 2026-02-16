import SwiftUI

extension StepHeatmap {
    struct MonthLabels: View {
        let entries: [MonthLabelEntry]
        let leadingOffset: CGFloat

        var body: some View {
            ForEach(entries) { entry in
                Text(entry.text)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(height: StepHeatmap.labelRowHeight, alignment: .bottomLeading)
                    .offset(x: leadingOffset + entry.offset)
            }
        }
    }

    struct HeatmapGrid: View {
        let columns: [[Date]]
        let stats: [Date: Int]
        let cellSize: CGFloat
        let spacing: CGFloat
        let maxValue: Int
        @Binding var selectedDate: Date?

        var body: some View {
            HStack(alignment: .top, spacing: spacing) {
                WeekdayLabels(cellSize: cellSize, spacing: spacing)
                ForEach(Array(columns.enumerated()), id: \.offset) { _, week in
                    VStack(spacing: spacing) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let date = StepHeatmap.cellDate(forWeek: week, weekday: weekday)
                            let value = date.flatMap { stats[$0] } ?? 0
                            let isSelected = date != nil && selectedDate == date
                            Rectangle()
                                .fill(HeatColor.color(for: value, maxValue: maxValue))
                                .frame(width: cellSize, height: cellSize)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    guard let date = date else { return }
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedDate = selectedDate == date ? nil : date
                                    }
                                }
                        }
                    }
                }
            }
        }
    }

    struct WeekdayLabels: View {
        let cellSize: CGFloat
        let spacing: CGFloat

        var body: some View {
            VStack(alignment: .center, spacing: spacing) {
                ForEach(0..<7, id: \.self) { index in
                    Text(symbol(for: index))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: StepHeatmap.weekdayLabelWidth, height: cellSize, alignment: .center)
                }
            }
        }

        private func symbol(for index: Int) -> String {
            guard StepHeatmap.weekdaySymbols.indices.contains(index) else { return "" }
            return StepHeatmap.weekdaySymbols[index]
        }
    }
}
