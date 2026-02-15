import SwiftUI

struct DayStat: Hashable {
    let date: Date
    let value: Int
}

enum HeatColor {
    static func color(for value: Int, maxValue: Int) -> Color {
        AppColors.heatmapColor(for: value, maxValue: maxValue)
    }
}
