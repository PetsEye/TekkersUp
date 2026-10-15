import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    static let background = Color(hex: 0x0D0D0E)
    static let panel = Color(hex: 0x111113)
    static let line = Color(hex: 0x3A3A3A)
    static let rule = Color(hex: 0xE9E9E9)
    static let text = Color(hex: 0xF2F2F2)
    static let muted = Color(hex: 0x8A8A8F)
    static let neon = Color(hex: 0xC6FF3D)
    static let neonDim = Color(hex: 0x3F5A0C)
    static let warn = Color(hex: 0xFF5D5D)
    static let body = Color(hex: 0xC9C9CE)
}

enum Space {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let huge: CGFloat = 48
}

enum Typo {
    static let display: CGFloat = 44
    static let title: CGFloat = 22
    static let body: CGFloat = 16
    static let label: CGFloat = 13
    static let micro: CGFloat = 11

    static func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

enum Tracking {
    static let tight: CGFloat = -1
    static let wide: CGFloat = 1
}

func formatNumber(_ value: Double) -> String {
    if value == value.rounded() {
        return String(Int(value))
    }
    return String(value)
}

func formatValue(_ value: Double, decimals: Int, unit: String) -> String {
    String(format: "%.\(decimals)f", value) + unit
}
