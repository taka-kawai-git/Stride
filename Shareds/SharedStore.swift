import Foundation
import WidgetKit
import os.log

extension Notification.Name {
    static let stepsDidUpdate = Notification.Name("stepsDidUpdate")
}

enum SharedStore {
    private static let suite: UserDefaults? = UserDefaults(suiteName: AppGroupID.suite)
    

    // ================ Appearance ================

    private static let appearanceKey = "appearance"

    static func loadAppearance() -> SharedAppearance {
        guard
            let suite,
            let data = suite.data(forKey: appearanceKey),
            let value = try? JSONDecoder().decode(SharedAppearance.self, from: data)
        else {
            return .default
        }
        return value
    }

    static func saveAppearance(_ value: SharedAppearance) {
        var kind = StrideWidgetKind.kind
        guard let suite else { return }
        let data = try? JSONEncoder().encode(value)
        suite.set(data, forKey: appearanceKey)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
    }

    // ================ Current Steps ================

    private static let stepsKey = "currentSteps"
    private static let lastUpdatedKey = "currentSteps_lastUpdated"

    static func saveCurrentSteps(_ steps: Int) {
        let log = Logger(category: "root")
        guard let suite else { return }
        
        let previousSteps = suite.integer(forKey: stepsKey)
        if previousSteps == steps { return }
        
        let now = Date()

        suite.set(steps, forKey: stepsKey)
        suite.set(now.timeIntervalSince1970, forKey: lastUpdatedKey)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .stepsDidUpdate, object: nil, userInfo: ["steps": steps])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            log.debug("SharedStore: save today steps")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static func loadCurrentSteps() -> Int {
        guard let suite else { return 0 }
        return suite.integer(forKey: stepsKey)
    }

    static func loadLastUpdated() -> Date? {
        guard let suite else { return nil }
        let t = suite.double(forKey: lastUpdatedKey)
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }

    // ================ Authorization Request Flag ================

    private static let didRequestAuthorizationKey = "didRequestAuthorization"

    static func saveDidRequestAuthorization(_ didRequest: Bool) {
        guard let suite else { return }
        suite.set(didRequest, forKey: didRequestAuthorizationKey)
    }

    static func hasRequestedAuthorization() -> Bool {
        guard let suite else { return false }
        return suite.bool(forKey: didRequestAuthorizationKey)
    }
}
