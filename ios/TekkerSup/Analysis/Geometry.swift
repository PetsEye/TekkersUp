import Foundation

struct Point: Equatable, Hashable {
    var x: Double
    var y: Double
}

func angleDeg(_ a: Point, _ b: Point, _ c: Point) -> Double {
    let v1x = a.x - b.x
    let v1y = a.y - b.y
    let v2x = c.x - b.x
    let v2y = c.y - b.y
    let denom = hypot(v1x, v1y) * hypot(v2x, v2y)
    if denom == 0 { return 180 }
    let cos = (v1x * v2x + v1y * v2y) / denom
    return acos(min(1, max(-1, cos))) * 180 / Double.pi
}

func dist(_ a: Point, _ b: Point) -> Double {
    hypot(a.x - b.x, a.y - b.y)
}

func midpoint(_ a: Point, _ b: Point) -> Point {
    Point(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
}

func mean(_ xs: [Double]) -> Double {
    xs.isEmpty ? 0 : xs.reduce(0, +) / Double(xs.count)
}
