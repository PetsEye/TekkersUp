import SwiftUI

private let battleShots = 2

struct BattleView: View {
    enum Phase: Hashable {
        case setup
        case shooterA
        case shooterB
        case result
    }

    let defaultName: String
    let side: Side
    let onSave: ([SessionRecord]) -> Void
    let onExit: () -> Void

    @State private var phase: Phase = .setup
    @State private var drill = DrillCatalog.all[0]
    @State private var nameA: String
    @State private var nameB = ""
    @State private var recA: SessionRecord?
    @State private var recB: SessionRecord?

    init(defaultName: String, side: Side, onSave: @escaping ([SessionRecord]) -> Void, onExit: @escaping () -> Void) {
        self.defaultName = defaultName
        self.side = side
        self.onSave = onSave
        self.onExit = onExit
        _nameA = State(initialValue: defaultName)
    }

    private var a: String {
        nameA.trimmingCharacters(in: .whitespaces)
    }

    private var b: String {
        nameB.trimmingCharacters(in: .whitespaces)
    }

    private var namesClash: Bool {
        !a.isEmpty && a.lowercased() == b.lowercased()
    }

    var body: some View {
        switch phase {
        case .setup:
            setupView
        case .shooterA:
            shooterView(name: a, number: 1)
        case .shooterB:
            shooterView(name: b, number: 2)
        case .result:
            resultView
        }
    }

    private var setupView: some View {
        let ready = !a.isEmpty && !b.isEmpty && !namesClash
        return Screen {
            VStack(alignment: .leading, spacing: Space.xs) {
                Eyebrow("Battle / \(battleShots) shots each", accent: true)
                Headline("Head\nto head")
            }

            Text("Two players take turns on the same phone. Each shoots \(battleShots) times, and the app ranks technique by average rep score.")
                .foregroundStyle(Theme.muted)
                .lineSpacing(Space.xxs)

            SectionHead("Drill")
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: Space.xs), GridItem(.flexible(), spacing: Space.xs)],
                spacing: Space.xs
            ) {
                ForEach(DrillCatalog.all) { option in
                    let selected = option.id == drill.id
                    Button {
                        drill = option
                    } label: {
                        Text(option.name)
                            .font(Typo.font(Typo.label, .black))
                            .textCase(.uppercase)
                            .tracking(Tracking.wide)
                            .foregroundStyle(selected ? Theme.neon : Theme.muted)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(Space.md)
                            .background(Theme.panel)
                            .overlay(Rectangle().strokeBorder(selected ? Theme.neon : Theme.line, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
            }

            SectionHead("Players")
            VStack(alignment: .leading, spacing: Space.sm) {
                TextField("Player 1", text: $nameA)
                    .textFieldStyle(.plain)
                    .fieldBox()
                TextField("Player 2", text: $nameB)
                    .textFieldStyle(.plain)
                    .fieldBox()
                if namesClash {
                    Text("Players need different names.")
                        .font(Typo.font(Typo.label))
                        .foregroundStyle(Theme.warn)
                }
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                Button("Start battle") { phase = .shooterA }
                    .buttonStyle(.tekker(.primary, fullWidth: true))
                    .disabled(!ready)
                Button("Back", action: onExit)
                    .buttonStyle(.tekker(.ghost, fullWidth: true))
            }
            .padding(.top, Space.sm)
        }
    }

    @ViewBuilder
    private func shooterView(name: String, number: Int) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            VStack(alignment: .leading, spacing: Space.xs) {
                Eyebrow("Shooter \(number) of 2", accent: true)
                Text("\(name) takes \(battleShots) shots")
                    .font(Typo.font(Typo.title, .black))
                    .textCase(.uppercase)
                    .tracking(Tracking.tight)
                    .foregroundStyle(Theme.text)
            }
            .padding(Space.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.panel)
            .overlay(Rectangle().strokeBorder(Theme.neon, lineWidth: 2))
            .padding(.horizontal, Space.lg)
            .padding(.top, Space.sm)

            if number == 1 {
                SessionView(
                    drill: drill,
                    side: side,
                    playerName: name,
                    shotTarget: battleShots,
                    onFinish: { record in
                        recA = record
                        phase = .shooterB
                    },
                    onExit: onExit
                )
                .id(Phase.shooterA)
            } else {
                SessionView(
                    drill: drill,
                    side: side,
                    playerName: name,
                    shotTarget: battleShots,
                    onFinish: { record in
                        recB = record
                        phase = .result
                    },
                    onExit: onExit
                )
                .id(Phase.shooterB)
            }
        }
    }

    @ViewBuilder
    private var resultView: some View {
        if let recA, let recB {
            let winner: String? = recA.score == recB.score ? nil : (recA.score > recB.score ? a : b)
            Screen {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Eyebrow("Result / \(drill.name)", accent: true)
                    Headline(winner ?? "Draw")
                }

                Text(winner.map { "\($0) has the better technique over \(battleShots) shots." }
                     ?? "Both players scored the same. Neither technique edged out the other.")
                    .foregroundStyle(Theme.body)
                    .lineSpacing(Space.xxs)

                HStack(alignment: .top, spacing: Space.sm) {
                    resultCard(name: a, record: recA, won: winner == a)
                    resultCard(name: b, record: recB, won: winner == b)
                }

                Text("Ranked by average rep score across both shooters' shots.")
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.muted)

                VStack(alignment: .leading, spacing: Space.sm) {
                    Button("Save and finish") {
                        onSave([recA, recB])
                        onExit()
                    }
                    .buttonStyle(.tekker(.primary, fullWidth: true))
                    Button("Rematch") {
                        self.recA = nil
                        self.recB = nil
                        phase = .setup
                    }
                    .buttonStyle(.tekker(.ghost, fullWidth: true))
                }
                .padding(.top, Space.sm)
            }
        } else {
            EmptyView()
        }
    }

    private func resultCard(name: String, record: SessionRecord, won: Bool) -> some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Eyebrow(name)
            Text("\(record.score)")
                .font(Typo.font(Typo.display))
                .foregroundStyle(won ? Theme.neon : Theme.text)
                .lineLimit(1)
            Text("\(record.reps.count) of \(battleShots) shots scored")
                .font(Typo.font(Typo.micro))
                .foregroundStyle(Theme.muted)
            VStack(alignment: .leading, spacing: Space.xs) {
                ForEach(Array(record.pointers.prefix(2)), id: \.self) { pointer in
                    BulletLine(text: pointer)
                }
            }
            .font(Typo.font(Typo.label))
            .padding(.top, Space.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.md)
        .background(won ? Theme.neonDim : Theme.panel)
        .overlay(Rectangle().strokeBorder(won ? Theme.neon : Theme.line, lineWidth: 2))
    }
}
