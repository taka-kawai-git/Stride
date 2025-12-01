import Foundation

struct SharedAppearance: Codable, Equatable {
    var emoji: String
    var gradientID: String   // 例: "greenMintBlue", "pinkPurple", "mono"
    var goal: Int

    static let `default` = SharedAppearance(
        emoji: "🏃🏻‍♀️",
        gradientID: "pinkPurple",
        goal: 10_000
    )
}