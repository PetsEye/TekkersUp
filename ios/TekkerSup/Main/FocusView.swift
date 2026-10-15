import SwiftUI

struct FocusView: View {
    let onStart: (Drill) -> Void
    let onBattle: () -> Void

    @EnvironmentObject private var store: AppStore

    var body: some View {
        let sessions = store.sessions
        let avg = sessions.isEmpty ? 0 : Int(mean(sessions.map { Double($0.score) }).rounded())
        let best = sessions.map(\.score).max() ?? 0
        let count = DrillCatalog.all.count
        let countText = String(format: "%02d / %02d", count, count)

        Screen {
            VStack(alignment: .leading, spacing: Space.xs) {
                Eyebrow("Player / V.01")
                Headline("Training\nSession")
            }

            StatsRow(items: [
                StatItem("Sessions", "\(sessions.count)"),
                StatItem("Avg score", "\(avg)"),
                StatItem("Best", "\(best)", accent: true),
            ])

            SectionHead("Battle")
            VStack(alignment: .leading, spacing: Space.md) {
                Text("Two players, two shots each. The app picks who has the better technique.")
                    .foregroundStyle(Theme.body)
                    .lineSpacing(Space.xxs)
                Button("Start a battle", action: onBattle)
                    .buttonStyle(.tekker(.primary, fullWidth: true))
            }
            .padding(.vertical, Space.md)
            Rule(weight: 1, color: Theme.line)

            SectionHead("Current drills", trailing: countText)

            ForEach(Array(DrillCatalog.all.enumerated()), id: \.element.id) { index, drill in
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: Space.md) {
                        DrillThumb(index: index)
                        VStack(alignment: .leading, spacing: Space.xs) {
                            Eyebrow(drill.category, accent: true)
                            Headline(drill.name, size: Typo.title)
                            HStack(spacing: Space.xs) {
                                Tag("\(drill.metrics.count) metrics", solid: true)
                                Tag("\(store.config.kickingSide.label) foot")
                            }
                            Button("Start drill") { onStart(drill) }
                                .buttonStyle(.tekker(.primary, small: true))
                                .padding(.top, Space.xs)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, Space.md)
                    Rule(weight: 1, color: Theme.line)
                }
            }
        }
    }
}
