import SwiftUI

struct DayStat: Hashable {
    let date: Date
    let value: Int
}

enum HeatColor {
    static func color(for value: Int, maxValue: Int) -> Color {
        guard maxValue > 0 else { return Color.gray.opacity(0.15) }

        let ratio = Double(value) / Double(maxValue)
        switch ratio {
        case ..<0.1:
            return Color.gray.opacity(0.15)
        case ..<0.3:
            return Color.blue.opacity(0.35)
        case ..<0.5:
            return Color.blue.opacity(0.55)
        case ..<0.8:
            return Color.blue.opacity(0.75)
        default:
            return Color.blue
        }
    }
}
