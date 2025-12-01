import Foundation

/// Immutable representation of a measured step count for a specific day.
struct StepCount: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let steps: Int
}
