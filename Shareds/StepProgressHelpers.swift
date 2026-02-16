import SwiftUI

func stepProgressRate(steps: Int, goal: Int) -> CGFloat {
    guard goal > 0 else { return 0 }
    return min(CGFloat(steps) / CGFloat(goal), 1)
}

func stepProgressPercentageText(rate: CGFloat) -> String {
    String(format: "%.0f%%", rate * 100)
}
