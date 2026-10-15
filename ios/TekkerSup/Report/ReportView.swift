import SwiftUI

struct ReportView: View {
    let session: SessionRecord
    let onTrainAgain: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var shots: [RepShot] {
        session.reps.compactMap(\.shot)
    }

    private var durationText: String {
        let total = session.durationSeconds
        return "\(total / 60):" + String(format: "%02d", total % 60)
    }

    var body: some View {
        Screen {
            HStack(alignment: .center) {
                Button("← Log") { dismiss() }
                    .buttonStyle(.tekker(.ghost, small: true))
                Spacer()
                Eyebrow("Report")
            }

            VStack(alignment: .leading, spacing: Space.xs) {
                if let drill = session.drill {
                    Eyebrow(drill.category, accent: true)
                    Headline(drill.name)
                }
            }

            StatsRow(items: [
                StatItem("Score", "\(session.score)", accent: true),
                StatItem("Reps", "\(session.reps.count)"),
                StatItem("Duration", durationText),
            ])

            if session.reps.isEmpty {
                Text("No reps were detected. Check that the full body is in frame and the striking leg is visible, then try again.")
                    .foregroundStyle(Theme.muted)
                    .lineSpacing(Space.xxs)
                    .card()
            } else {
                metricsSection
                pointersSection
                repsSection
            }

            Button("Train again", action: onTrainAgain)
                .buttonStyle(.tekker(.primary, fullWidth: true))
                .padding(.top, Space.sm)
        }
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            SectionHead("Metrics vs target")
            HStack {
                Eyebrow("Metric")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Eyebrow("Avg")
                    .frame(width: 72, alignment: .trailing)
                Eyebrow("Target")
                    .frame(width: 96, alignment: .trailing)
                Eyebrow("In range")
                    .frame(width: 72, alignment: .trailing)
            }
            .padding(.top, Space.xs)
            ForEach(session.summaries) { summary in
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(summary.label)
                            .foregroundStyle(Theme.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(formatValue(summary.avg, decimals: summary.decimals, unit: summary.unit))
                            .frame(width: 72, alignment: .trailing)
                        Text("\(formatNumber(summary.min))-\(formatNumber(summary.max))\(summary.unit)")
                            .foregroundStyle(Theme.neon)
                            .frame(width: 96, alignment: .trailing)
                        Text("\(summary.inRangePct)%")
                            .frame(width: 72, alignment: .trailing)
                    }
                    .font(Typo.font(Typo.label))
                    .padding(.vertical, Space.sm)
                    Rule(weight: 1, color: Theme.line)
                }
            }
        }
    }

    private var pointersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHead("Pointers")
                .padding(.top, Space.xl)
            ForEach(session.pointers, id: \.self) { pointer in
                VStack(spacing: 0) {
                    (Text("→ ").foregroundStyle(Theme.neon) + Text(pointer).foregroundStyle(Theme.body))
                        .font(Typo.font(Typo.body))
                        .lineSpacing(Space.xxs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, Space.sm)
                    Rule(weight: 1, color: Theme.line)
                }
            }
        }
    }

    private var repsSection: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHead("Reps")
                .padding(.top, Space.xl)

            if !shots.isEmpty {
                SectionHead("Shots")
                    .padding(.top, Space.xs)
                let onTarget = shots.filter(\.onTarget).count
                let average = shots.reduce(0) { $0 + $1.speedKmh } / Double(shots.count)
                let fastest = shots.map(\.speedKmh).max() ?? 0
                KeyValueRow(label: "On target", value: "\(onTarget) of \(shots.count)", accent: true)
                KeyValueRow(label: "Average speed", value: "\(Int(average.rounded())) km/h")
                KeyValueRow(label: "Fastest shot", value: "\(Int(fastest.rounded())) km/h")
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: Space.xs, alignment: .leading)], alignment: .leading, spacing: Space.xs) {
                ForEach(session.reps) { rep in
                    repChip(rep)
                }
            }
            .padding(.top, Space.xs)
        }
    }

    private func repChip(_ rep: RepResult) -> some View {
        HStack(spacing: Space.xs) {
            Text("#\(rep.index)")
                .foregroundStyle(Theme.muted)
            Text("\(rep.score)")
                .font(Typo.font(Typo.label, .black))
            if let shot = rep.shot {
                Text("\(Int(shot.speedKmh.rounded())) km/h \(shot.onTarget ? "on target" : "off target")")
                    .foregroundStyle(Theme.muted)
            }
        }
        .font(Typo.font(Typo.label))
        .padding(.horizontal, Space.sm)
        .padding(.vertical, Space.xs)
        .overlay(Rectangle().strokeBorder(Theme.rule, lineWidth: 1))
    }
}

private struct KeyValueRow: View {
    let label: String
    let value: String
    var accent = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .foregroundStyle(Theme.body)
                Spacer()
                Text(value)
                    .foregroundStyle(accent ? Theme.neon : Theme.text)
            }
            .font(Typo.font(Typo.label))
            .padding(.vertical, Space.sm)
            Rule(weight: 1, color: Theme.line)
        }
    }
}
