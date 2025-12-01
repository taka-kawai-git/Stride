import WidgetKit
import os.log

private let log = Logger(subsystem: "StrideWidget", category: "TimelineProvider")

struct StepProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepEntry {
        let appearance = SharedStore.loadAppearance()
        return StepEntry(date: .now, steps: 1_000, emoji: appearance.emoji, gradientID: appearance.gradientID, goal: appearance.goal, lastUpdated: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (StepEntry) -> Void) {
        let appearance = SharedStore.loadAppearance()
        let steps = SharedStore.loadCurrentSteps()
        let lastUpdated = context.isPreview ? Date() : (SharedStore.loadLastUpdated() ?? Date())

        completion(StepEntry(date: .now, steps: steps > 0 ? steps : 1_000, emoji: appearance.emoji, gradientID: appearance.gradientID, goal: appearance.goal, lastUpdated: lastUpdated))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepEntry>) -> Void) {
        let appearance = SharedStore.loadAppearance()
        let steps = SharedStore.loadCurrentSteps()
        let lastUpdated = SharedStore.loadLastUpdated()
        
        log.debug("StepWidget getTimeline steps=\(steps)")
        
        let entry = StepEntry(
            date: Date(),
            steps: steps == 0 ? 999_999 : steps,
            emoji: appearance.emoji,
            gradientID: appearance.gradientID,
            goal: appearance.goal,
            lastUpdated: lastUpdated
        )
        
        let next = Date().addingTimeInterval(30)
        completion(Timeline(entries: [entry], policy: .never))
    }
}
