import SwiftUI

enum TekkerButtonKind {
    case primary
    case ghost
    case danger
}

struct TekkerButtonStyle: ButtonStyle {
    var kind: TekkerButtonKind = .ghost
    var small = false
    var fullWidth = false

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let isPrimary = kind == .primary
        let foreground: Color = {
            switch kind {
            case .primary: return .black
            case .ghost: return Theme.rule
            case .danger: return Theme.warn
            }
        }()
        let border: Color = {
            switch kind {
            case .primary: return Theme.neon
            case .ghost: return Theme.rule
            case .danger: return Theme.warn
            }
        }()

        return configuration.label
            .font(Typo.font(Typo.label, .black))
            .textCase(.uppercase)
            .tracking(Tracking.wide)
            .foregroundStyle(foreground)
            .lineLimit(1)
            .padding(.horizontal, small ? Space.sm : Space.md)
            .padding(.vertical, small ? Space.xs : Space.sm)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(isPrimary ? Theme.neon : (kind == .ghost ? Theme.panel : Color.clear))
            .overlay(Rectangle().strokeBorder(border, lineWidth: 2))
            .offset(x: isPrimary && pressed ? 3 : 0, y: isPrimary && pressed ? 3 : 0)
            .background {
                if isPrimary {
                    Rectangle()
                        .fill(Theme.neonDim)
                        .offset(x: pressed ? 2 : 5, y: pressed ? 2 : 5)
                }
            }
            .padding(.trailing, isPrimary ? Space.xs : 0)
            .padding(.bottom, isPrimary ? Space.xs : 0)
            .opacity(isEnabled ? 1 : 0.4)
    }
}

extension ButtonStyle where Self == TekkerButtonStyle {
    static func tekker(_ kind: TekkerButtonKind = .ghost, small: Bool = false, fullWidth: Bool = false) -> TekkerButtonStyle {
        TekkerButtonStyle(kind: kind, small: small, fullWidth: fullWidth)
    }
}
