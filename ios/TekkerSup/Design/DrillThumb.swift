import SwiftUI

struct DrillThumb: View {
    let index: Int

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 29
            var x: CGFloat = 0
            while x <= size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Theme.line), lineWidth: 1)
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Theme.line), lineWidth: 1)
                y += step
            }
            let ring = CGRect(x: 14, y: size.height - 14 - 34, width: 34, height: 34)
            context.stroke(Path(ellipseIn: ring), with: .color(Theme.neon), lineWidth: 2)
        }
        .frame(width: 116, height: 116)
        .background(index % 2 == 0 ? Color(hex: 0x1A1A1C) : Color(hex: 0x0F1A06))
        .overlay(Rectangle().strokeBorder(Theme.rule, lineWidth: 2))
        .clipped()
        .accessibilityHidden(true)
    }
}
