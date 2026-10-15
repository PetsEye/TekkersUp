import SwiftUI

struct Screen<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                content
            }
            .font(Typo.font(Typo.body))
            .foregroundStyle(Theme.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Space.lg)
            .padding(.top, Space.xl)
            .padding(.bottom, Space.huge)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct Headline: View {
    let text: String
    var size: CGFloat = Typo.display
    var color: Color = Theme.neon

    init(_ text: String, size: CGFloat = Typo.display, color: Color = Theme.neon) {
        self.text = text
        self.size = size
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(Typo.font(size, .black))
            .textCase(.uppercase)
            .tracking(Tracking.tight)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct Eyebrow: View {
    let text: String
    var accent = false

    init(_ text: String, accent: Bool = false) {
        self.text = text
        self.accent = accent
    }

    var body: some View {
        Text(text)
            .font(Typo.font(Typo.micro).italic())
            .foregroundStyle(accent ? Theme.neon : Theme.muted)
    }
}

struct SectionHead: View {
    let title: String
    var trailing: String?

    init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(Typo.font(Typo.body, .black).italic())
                    .textCase(.uppercase)
                    .tracking(Tracking.tight)
                    .foregroundStyle(Theme.text)
                Spacer(minLength: Space.xs)
                if let trailing {
                    Text(trailing)
                        .font(Typo.font(Typo.body))
                        .foregroundStyle(Theme.muted)
                }
            }
            .padding(.vertical, Space.sm)
            Rule(weight: 2)
        }
    }
}

struct Rule: View {
    var weight: CGFloat = 1
    var color: Color = Theme.rule

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: weight)
    }
}

struct ListDivider: View {
    var body: some View {
        Divider()
            .overlay(Theme.line)
            .padding(.leading, Space.md)
    }
}

struct StatItem: Identifiable {
    let id: String
    let label: String
    let value: String
    var accent = false

    init(_ label: String, _ value: String, accent: Bool = false) {
        self.id = label
        self.label = label
        self.value = value
        self.accent = accent
    }
}

struct StatsRow: View {
    let items: [StatItem]

    var body: some View {
        VStack(spacing: 0) {
            Rule(weight: 2)
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    VStack(alignment: .leading, spacing: Space.xs) {
                        Text(item.label)
                            .font(Typo.font(Typo.micro).italic())
                            .foregroundStyle(item.accent ? Color.black : Theme.muted)
                        Text(item.value)
                            .font(Typo.font(Typo.title, .regular))
                            .foregroundStyle(item.accent ? Color.black : Theme.text)
                            .contentTransition(.numericText())
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Space.sm)
                    .padding(.vertical, Space.sm)
                    .background(item.accent ? Theme.neon : Color.clear)
                    .overlay(alignment: .trailing) {
                        if index < items.count - 1 {
                            Rectangle()
                                .fill(Theme.line)
                                .frame(width: 1)
                        }
                    }
                }
            }
            Rule(weight: 2)
        }
    }
}

struct Tag: View {
    let text: String
    var solid = false

    init(_ text: String, solid: Bool = false) {
        self.text = text
        self.solid = solid
    }

    var body: some View {
        Text(text)
            .font(Typo.font(Typo.micro))
            .textCase(.uppercase)
            .tracking(Tracking.wide)
            .foregroundStyle(solid ? Color.black : Theme.text)
            .padding(.horizontal, Space.xs)
            .padding(.vertical, Space.xxs)
            .background(solid ? Theme.neon : Color.clear)
            .overlay(Rectangle().strokeBorder(solid ? Theme.neon : Theme.rule, lineWidth: 1))
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Space.md)
            .background(Theme.panel)
            .overlay(Rectangle().strokeBorder(Theme.rule, lineWidth: 2))
    }
}

extension View {
    func card() -> some View {
        modifier(CardStyle())
    }

    func fieldBox() -> some View {
        self
            .font(Typo.font(Typo.body))
            .foregroundStyle(Theme.text)
            .tint(Theme.neon)
            .padding(Space.md)
            .background(Theme.panel)
            .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 2))
    }
}

struct PasswordField: View {
    let placeholder: String
    @Binding var text: String
    let reveal: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: Space.xs) {
            Group {
                if reveal {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.plain)
            Button(reveal ? "Hide" : "Show", action: onToggle)
                .font(Typo.font(Typo.micro, .black))
                .textCase(.uppercase)
                .foregroundStyle(Theme.neon)
                .buttonStyle(.plain)
        }
        .fieldBox()
    }
}

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: Space.sm) {
                ZStack {
                    Rectangle()
                        .strokeBorder(Theme.rule, lineWidth: 2)
                    if configuration.isOn {
                        Rectangle()
                            .fill(Theme.neon)
                            .padding(Space.xxs)
                    }
                }
                .frame(width: Space.lg, height: Space.lg)
                configuration.label
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}
