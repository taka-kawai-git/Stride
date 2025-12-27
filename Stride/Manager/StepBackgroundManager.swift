import Foundation
import WidgetKit
import os.log

final class StepBackgroundManager: Sendable {
    static let shared = StepBackgroundManager()
    
    private let log = Logger(category: "manager")
    private let lastReloadKey = "lastWidgetReloadTimestamp"

    private init() {}

    func handleStepUpdate(steps: Int) async {
        log.tDebug("Processing background update: \(steps)")
        
        SharedStore.saveCurrentSteps(steps)

        if shouldReloadWidget() {
            log.tDebug("Budget check passed. Reloading widget.")
            WidgetCenter.shared.reloadTimelines(ofKind: StrideWidgetKind.kind)
            saveLastReloadTime()
        } else {
            log.tDebug("Skipping widget reload to save budget.")
        }
    }
    
    private func shouldReloadWidget() -> Bool {
        let lastReload = UserDefaults.standard.object(forKey: lastReloadKey) as? Date ?? .distantPast
        return Date().timeIntervalSince(lastReload) > 1200
    }
    
    private func saveLastReloadTime() {
        UserDefaults.standard.set(Date(), forKey: lastReloadKey)
    }
}
