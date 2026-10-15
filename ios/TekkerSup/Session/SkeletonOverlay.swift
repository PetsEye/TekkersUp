import SwiftUI

/// Maps analysis space (height 1, width aspect) onto a view using the same aspect-fill
/// geometry as the camera preview.
struct AspectFill {
    let viewSize: CGSize
    let aspect: Double

    var scale: Double {
        max(Double(viewSize.width) / aspect, Double(viewSize.height))
    }

    var offsetX: Double {
        (Double(viewSize.width) - aspect * scale) / 2
    }

    var offsetY: Double {
        (Double(viewSize.height) - scale) / 2
    }

    func toView(_ p: Point) -> CGPoint {
        CGPoint(x: offsetX + p.x * scale, y: offsetY + p.y * scale)
    }

    func toAnalysis(_ p: CGPoint) -> Point {
        Point(
            x: (Double(p.x) - offsetX) / scale,
            y: (Double(p.y) - offsetY) / scale
        )
    }
}

struct SkeletonOverlay: View {
    let size: CGSize
    let aspect: Double
    let pose: [Int: Point]
    let goal: Goal?
    let posts: [Point]
    let ballBox: CGRect?

    private static let bones: [(Int, Int)] = [
        (11, 12), (11, 23), (12, 24), (23, 24), (23, 25), (25, 27), (24, 26), (26, 28),
        (11, 13), (13, 15), (12, 14), (14, 16),
    ]

    var body: some View {
        Canvas { context, _ in
            let map = AspectFill(viewSize: size, aspect: aspect)
            drawSkeleton(in: &context, map: map)
            if let goal {
                drawGoal(goal, in: &context, map: map)
            }
            for post in posts {
                let p = map.toView(post)
                context.fill(
                    Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)),
                    with: .color(Theme.neon)
                )
            }
            if let ballBox {
                let origin = map.toView(Point(x: Double(ballBox.minX), y: Double(ballBox.minY)))
                let rect = CGRect(
                    x: origin.x,
                    y: origin.y,
                    width: CGFloat(Double(ballBox.width) * map.scale),
                    height: CGFloat(Double(ballBox.height) * map.scale)
                )
                context.stroke(Path(rect), with: .color(.white), lineWidth: 2)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawSkeleton(in context: inout GraphicsContext, map: AspectFill) {
        var lines = Path()
        for (a, b) in Self.bones {
            guard let p = pose[a], let q = pose[b] else { continue }
            lines.move(to: map.toView(p))
            lines.addLine(to: map.toView(q))
        }
        context.stroke(lines, with: .color(Theme.neon), lineWidth: 2)

        for point in pose.values {
            let c = map.toView(point)
            context.fill(
                Path(ellipseIn: CGRect(x: c.x - 3.5, y: c.y - 3.5, width: 7, height: 7)),
                with: .color(Theme.neon)
            )
        }
    }

    private func drawGoal(_ goal: Goal, in context: inout GraphicsContext, map: AspectFill) {
        let topLeft = map.toView(Point(x: goal.left.x, y: goal.top))
        let bottomRight = map.toView(Point(x: goal.right.x, y: goal.ground))
        let rect = CGRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
        context.stroke(
            Path(rect),
            with: .color(Theme.neon),
            style: StrokeStyle(lineWidth: 2, dash: [8, 6])
        )
    }
}
