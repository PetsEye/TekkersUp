import SwiftUI

struct WelcomeView: View {
    let onPlay: () -> Void
    let onRegister: () -> Void
    let onAbout: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xxl) {
            BrandMark()
            Spacer(minLength: Space.xl)
            VStack(alignment: .leading, spacing: Space.md) {
                (Text("Start Your\nTraining ").foregroundStyle(Theme.text)
                    + Text("Today!").foregroundStyle(Theme.neon))
                    .font(Typo.font(Typo.display, .black))
                    .textCase(.uppercase)
                    .tracking(Tracking.tight)
                HStack(alignment: .top, spacing: Space.sm) {
                    Rectangle()
                        .fill(Theme.neon)
                        .frame(width: 2)
                    Text("Simple drills to sharpen your technique, power and balance. Check your form with your phone.")
                        .font(Typo.font(Typo.body))
                        .foregroundStyle(Theme.muted)
                        .lineSpacing(Space.xxs)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: Space.xl)
            HStack(spacing: Space.sm) {
                Button("Play Now", action: onPlay)
                    .buttonStyle(.tekker(.ghost, fullWidth: true))
                Button("Register Now", action: onRegister)
                    .buttonStyle(.tekker(.primary, fullWidth: true))
            }
            Button("How TEKKERSUP works", action: onAbout)
                .buttonStyle(.tekker(.ghost, fullWidth: true))
        }
        .padding(Space.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
