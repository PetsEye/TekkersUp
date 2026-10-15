import Foundation

struct FrameMetrics: Equatable {
    var kick: Double
    var support: Double
    var lean: Double
    var armSpread: Double
}

private struct JointIndices {
    let shoulder: Int
    let hip: Int
    let knee: Int
    let ankle: Int
    let wrist: Int

    static let left = JointIndices(shoulder: 11, hip: 23, knee: 25, ankle: 27, wrist: 15)
    static let right = JointIndices(shoulder: 12, hip: 24, knee: 26, ankle: 28, wrist: 16)
}

private let maxConcernPct = 70
private let maxCycleFrames = 300

/// Measures posture metrics for one frame. Landmarks are already in analysis space.
func measureFrame(_ lm: [Int: Point], kicking: Side) -> FrameMetrics? {
    let k = kicking == .right ? JointIndices.right : JointIndices.left
    let s = kicking == .right ? JointIndices.left : JointIndices.right
    let required = [k.hip, k.knee, k.ankle, s.hip, s.knee, s.ankle, 11, 12, 23, 24, 15, 16]
    guard required.allSatisfy({ lm[$0] != nil }) else { return nil }

    func pt(_ i: Int) -> Point {
        lm[i] ?? Point(x: 0, y: 0)
    }

    let shoulderMid = midpoint(pt(11), pt(12))
    let hipMid = midpoint(pt(23), pt(24))
    let lean = atan2(abs(shoulderMid.x - hipMid.x), abs(shoulderMid.y - hipMid.y)) * 180 / Double.pi
    let shoulderWidth = dist(pt(11), pt(12))

    return FrameMetrics(
        kick: angleDeg(pt(k.hip), pt(k.knee), pt(k.ankle)),
        support: angleDeg(pt(s.hip), pt(s.knee), pt(s.ankle)),
        lean: lean,
        armSpread: shoulderWidth > 0 ? dist(pt(15), pt(16)) / shoulderWidth : 0
    )
}

func liveValue(_ m: FrameMetrics, key: MetricKey) -> Double {
    switch key {
    case .backswing: return m.kick
    case .support: return m.support
    case .lean: return m.lean
    case .arms: return m.armSpread
    }
}

private func evaluateRep(drill: Drill, index: Int, values: [MetricKey: Double]) -> RepResult {
    var passed: [MetricKey: Bool] = [:]
    var hits = 0
    for t in drill.metrics {
        let v = values[t.key] ?? 0
        let ok = v >= t.min && v <= t.max
        passed[t.key] = ok
        if ok { hits += 1 }
    }
    let score = Int((Double(hits) / Double(drill.metrics.count) * 100).rounded())
    return RepResult(index: index, values: values, passed: passed, score: score, t: nil, shot: nil)
}

/// Detects strike cycles: cock the kicking leg (knee below cockAngle), then extend past extendAngle.
final class RepDetector {
    private let drill: Drill
    private var cocked = false
    private var samples: [FrameMetrics] = []
    private var minKick = Double.infinity
    private var count = 0

    init(drill: Drill) {
        self.drill = drill
    }

    func reset() {
        cocked = false
        samples = []
        minKick = .infinity
        count = 0
    }

    func push(_ m: FrameMetrics?) -> RepResult? {
        guard let m else { return nil }

        if !cocked {
            if m.kick < drill.cockAngle {
                cocked = true
                samples = [m]
                minKick = m.kick
            }
            return nil
        }

        if m.kick > drill.extendAngle {
            let values: [MetricKey: Double] = [
                .backswing: minKick,
                .support: m.support,
                .lean: mean(samples.map(\.lean)),
                .arms: mean(samples.map(\.armSpread)),
            ]
            cocked = false
            samples = []
            count += 1
            return evaluateRep(drill: drill, index: count, values: values)
        }

        samples.append(m)
        minKick = min(minKick, m.kick)
        if samples.count > maxCycleFrames {
            cocked = false
            samples = []
        }
        return nil
    }
}

func buildSession(drill: Drill, side: Side, startedAt: Date, reps: [RepResult], playerName: String?) -> SessionRecord {
    let summaries: [MetricSummary] = drill.metrics.map { t in
        let vals = reps.map { $0.values[t.key] ?? 0 }
        let inRange = reps.filter { $0.passed[t.key] == true }.count
        return MetricSummary(
            key: t.key,
            label: t.label,
            unit: t.unit,
            decimals: t.decimals,
            min: t.min,
            max: t.max,
            avg: mean(vals),
            inRangePct: reps.isEmpty ? 0 : Int((Double(inRange) / Double(reps.count) * 100).rounded())
        )
    }

    var pointers: [String] = []
    if !reps.isEmpty {
        for (i, t) in drill.metrics.enumerated() {
            let s = summaries[i]
            if s.inRangePct >= maxConcernPct { continue }
            let tip = s.avg < t.min ? t.tipLow : t.tipHigh
            pointers.append("\(t.label): \(tip)")
        }
        if pointers.isEmpty {
            pointers.append("Solid, consistent form across the set. Next step: add speed and reps under pressure.")
        }
    }

    return SessionRecord(
        id: UUID(),
        drillId: drill.id,
        side: side,
        startedAt: startedAt,
        endedAt: Date(),
        reps: reps,
        score: reps.isEmpty ? 0 : Int(mean(reps.map { Double($0.score) }).rounded()),
        summaries: summaries,
        pointers: pointers,
        playerName: playerName
    )
}
