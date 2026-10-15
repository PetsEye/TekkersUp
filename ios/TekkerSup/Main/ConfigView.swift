import SwiftUI

struct ConfigView: View {
    @EnvironmentObject private var account: AccountStore
    @EnvironmentObject private var store: AppStore
    @State private var confirmClear = false

    var body: some View {
        Screen {
            VStack(alignment: .leading, spacing: Space.xs) {
                Eyebrow("Config / Setup")
                Headline("Setup\nConfig")
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                Eyebrow("Account", accent: true)
                Text("Signed in as \(account.user ?? "")")
                    .foregroundStyle(Theme.body)
                Button("Sign out") { account.signOut() }
                    .buttonStyle(.tekker(.ghost, fullWidth: true))
                    .padding(.top, Space.xs)
            }
            .card()

            VStack(alignment: .leading, spacing: Space.sm) {
                Eyebrow("Kicking foot", accent: true)
                Text("Which leg the analysis tracks as the striking leg.")
                    .foregroundStyle(Theme.muted)
                SideSegment(selection: $store.config.kickingSide)
                    .padding(.top, Space.xs)
            }
            .card()

            VStack(alignment: .leading, spacing: Space.sm) {
                Eyebrow("Camera setup", accent: true)
                VStack(alignment: .leading, spacing: Space.xs) {
                    BulletLine(text: "Prop the phone 2-3 m away at waist height.")
                    BulletLine(text: "Film from the side so the striking leg is visible.")
                    BulletLine(text: "Keep the full body in frame, head to feet.")
                    BulletLine(text: "Use good light and avoid strong backlight.")
                }
            }
            .card()

            VStack(alignment: .leading, spacing: Space.sm) {
                Eyebrow("Data", accent: true)
                Text("\(store.sessions.count) session(s) stored on this device.")
                    .foregroundStyle(Theme.muted)
                Button("Clear history") { confirmClear = true }
                    .buttonStyle(.tekker(.danger, fullWidth: true))
                    .disabled(store.sessions.isEmpty)
                    .padding(.top, Space.xs)
            }
            .card()
        }
        .confirmationDialog(
            "Delete all saved sessions on this device?",
            isPresented: $confirmClear,
            titleVisibility: .visible
        ) {
            Button("Clear history", role: .destructive) {
                store.clearSessions()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

private struct SideSegment: View {
    @Binding var selection: Side

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Side.allCases, id: \.self) { side in
                Button {
                    selection = side
                } label: {
                    Text(side.label)
                        .font(Typo.font(Typo.label, .black))
                        .textCase(.uppercase)
                        .tracking(Tracking.wide)
                        .foregroundStyle(selection == side ? Color.black : Theme.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Space.sm)
                        .background(selection == side ? Theme.neon : Color.clear)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(Rectangle().strokeBorder(Theme.rule, lineWidth: 2))
    }
}
