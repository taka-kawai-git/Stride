import Foundation
import WidgetKit
import os.log

extension Notification.Name {
    static let stepsDidUpdate = Notification.Name("stepsDidUpdate")
}

enum SharedStore {
    private static var suite: UserDefaults? {
        UserDefaults(suiteName: AppGroupID.suite)
    }

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

    private static let stepsKey = "currentSteps"
    private static let lastUpdatedKey = "currentSteps_lastUpdated"

    /// 今日の歩数を保存
    static func saveCurrentSteps(_ steps: Int) {
        let log = Logger(subsystem: "Stride", category: "Pedometer")
        guard let suite else { return }
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

    /// 今日の歩数を取得
    static func loadCurrentSteps() -> Int {
        guard let suite else { return 0 }
        return suite.integer(forKey: stepsKey)
    }

    /// 最終更新日時
    static func loadLastUpdated() -> Date? {
        guard let suite else { return nil }
        let t = suite.double(forKey: lastUpdatedKey)
        return t > 0 ? Date(timeIntervalSince1970: t) : nil
    }
}
