import WidgetKit

struct StepEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let emoji: String
    let gradientID: String
    let goal: Int
    let lastUpdated: Date?
}
