import Foundation

enum MetricKey: String, Codable, CaseIterable, Hashable {
    case backswing
    case support
    case lean
    case arms
}

struct MetricTarget: Hashable {
    let key: MetricKey
    let label: String
    let min: Double
    let max: Double
    let unit: String
    let decimals: Int
    let tipLow: String
    let tipHigh: String
}

struct Drill: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let blurb: String
    /// Kicking knee angle (degrees) below which the leg is considered cocked back.
    let cockAngle: Double
    /// Kicking knee angle (degrees) above which the strike/contact is considered complete.
    let extendAngle: Double
    let cues: [String]
    let metrics: [MetricTarget]
    /// Tracks the ball and goal for shot speed and accuracy.
    let tracksBall: Bool

    static func find(_ id: String) -> Drill? {
        DrillCatalog.all.first { $0.id == id }
    }
}
