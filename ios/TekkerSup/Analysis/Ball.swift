import Foundation

let goalWidthMeters = 7.32
let goalHeightMeters = 2.44

private let startMps = 6.0
private let endMps = 3.0
private let slowFrames = 3
private let lostMs = 500.0

struct Goal: Equatable {
    var left: Point
    var right: Point
    var ground: Double
    var top: Double
    var pxPerMeter: Double
}

struct Shot: Equatable {
    var speedKmh: Double
    var onTarget: Bool
    var t: Double
}

/// Builds the goal mouth from the two post bases. Scale comes from the known 7.32 m goal width.
func goalFromPosts(_ a: Point, _ b: Point) -> Goal {
    let left = a.x <= b.x ? a : b
    let right = a.x <= b.x ? b : a
    let pxPerMeter = max(1, right.x - left.x) / goalWidthMeters
    let ground = (left.y + right.y) / 2
    return Goal(
        left: left,
        right: right,
        ground: ground,
        top: ground - goalHeightMeters * pxPerMeter,
        pxPerMeter: pxPerMeter
    )
}

func inGoal(_ p: Point, _ goal: Goal) -> Bool {
    p.x >= goal.left.x && p.x <= goal.right.x && p.y >= goal.top && p.y <= goal.ground
}

/// Turns a stream of ball positions into shots: a shot starts when the ball moves fast and ends when it slows or is lost.
final class ShotTracker {
    private let goal: Goal
    private var last: (p: Point, t: Double)?
    private var moving: (peak: Double, points: [Point])?
    private var slowCount = 0

    init(goal: Goal) {
        self.goal = goal
    }

    func push(_ p: Point?, t: Double) -> Shot? {
        guard let p else {
            if moving != nil, let last, t - last.t > lostMs { return finish() }
            return nil
        }
        let prev = last
        last = (p, t)
        guard let prev, t > prev.t else { return nil }

        let mps = dist(p, prev.p) / goal.pxPerMeter / ((t - prev.t) / 1000)
        guard var current = moving else {
            if mps >= startMps {
                moving = (peak: mps, points: [prev.p, p])
                slowCount = 0
            }
            return nil
        }

        current.points.append(p)
        current.peak = max(current.peak, mps)
        moving = current
        slowCount = mps < endMps ? slowCount + 1 : 0
        return slowCount >= slowFrames ? finish() : nil
    }

    private func finish() -> Shot? {
        guard let m = moving else { return nil }
        moving = nil
        slowCount = 0
        return Shot(
            speedKmh: m.peak * 3.6,
            onTarget: m.points.contains { inGoal($0, goal) },
            t: last?.t ?? 0
        )
    }
}
