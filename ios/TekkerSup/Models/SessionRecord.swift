import Foundation

enum Side: String, Codable, CaseIterable, Hashable {
    case right
    case left

    var label: String {
        self == .right ? "Right" : "Left"
    }
}

struct RepShot: Codable, Hashable {
    var speedKmh: Double
    var onTarget: Bool
}

struct RepResult: Codable, Identifiable, Hashable {
    var index: Int
    var values: [MetricKey: Double]
    var passed: [MetricKey: Bool]
    var score: Int
    /// Milliseconds on the monotonic clock when the rep was detected.
    var t: Double?
    var shot: RepShot?

    var id: Int { index }
}

struct MetricSummary: Codable, Identifiable, Hashable {
    let key: MetricKey
    let label: String
    let unit: String
    let decimals: Int
    let min: Double
    let max: Double
    let avg: Double
    let inRangePct: Int

    var id: MetricKey { key }
}

struct SessionRecord: Codable, Identifiable, Hashable {
    var id: UUID
    var drillId: String
    var side: Side
    var startedAt: Date
    var endedAt: Date
    var reps: [RepResult]
    var score: Int
    var summaries: [MetricSummary]
    var pointers: [String]
    var playerName: String?

    var drill: Drill? {
        Drill.find(drillId)
    }

    var durationSeconds: Int {
        max(0, Int((endedAt.timeIntervalSince(startedAt)).rounded()))
    }
}
