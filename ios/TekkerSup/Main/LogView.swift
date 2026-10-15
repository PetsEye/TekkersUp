import Charts
import SwiftUI

struct LogView: View {
    @EnvironmentObject private var store: AppStore
    @State private var pendingDelete: UUID?

    private var recent: [SessionRecord] {
        Array(store.sessions.prefix(12).reversed())
    }

    var body: some View {
        Screen {
            VStack(alignment: .leading, spacing: Space.xs) {
                Eyebrow("Log / History")
                Headline("Session\nLog")
            }

            if !store.sessions.isEmpty {
                SectionHead("Progress", trailing: "last \(recent.count)")
                progressChart
            }

            SectionHead("Sessions")
            if store.sessions.isEmpty {
                Text("No sessions yet. Start a drill from Focus to record your first set.")
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Space.xl)
            }

            ForEach(store.sessions) { session in
                sessionRow(session)
            }
        }
        .confirmationDialog(
            "Delete this session?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = pendingDelete {
                    store.delete(id)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        }
    }

    private var progressChart: some View {
        VStack(spacing: 0) {
            Chart {
                ForEach(Array(recent.enumerated()), id: \.offset) { index, session in
                    BarMark(
                        x: .value("Session", index),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(Theme.neon)
                    .annotation(position: .top) {
                        Text("\(session.score)")
                            .font(Typo.font(Typo.micro))
                            .foregroundStyle(Theme.muted)
                    }
                }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 200)
            .padding(.top, Space.sm)
            Rule(weight: 2)
        }
    }

    private func sessionRow(_ session: SessionRecord) -> some View {
        let title = (session.drill?.name ?? "Drill") + (session.playerName.map { " / \($0)" } ?? "")
        return VStack(spacing: 0) {
            HStack(alignment: .center, spacing: Space.sm) {
                NavigationLink(value: session.id) {
                    HStack(alignment: .center, spacing: Space.sm) {
                        VStack(alignment: .leading, spacing: Space.xs) {
                            Eyebrow(title, accent: true)
                            Text("\(session.startedAt.formatted(date: .abbreviated, time: .shortened)) / \(session.reps.count) reps")
                                .font(Typo.font(Typo.micro))
                                .foregroundStyle(Theme.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(session.score)")
                            .font(Typo.font(Typo.title))
                            .foregroundStyle(Theme.neon)
                            .contentTransition(.numericText())
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button("Delete") {
                    pendingDelete = session.id
                }
                .buttonStyle(.tekker(.ghost, small: true))
            }
            .padding(.vertical, Space.md)
            ListDivider()
        }
    }
}
