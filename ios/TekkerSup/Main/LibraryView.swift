import SwiftUI

struct LibraryView: View {
    var body: some View {
        Screen {
            VStack(alignment: .leading, spacing: Space.xs) {
                Eyebrow("Library / Targets")
                Headline("Drill\nLibrary")
            }

            ForEach(DrillCatalog.all) { drill in
                VStack(alignment: .leading, spacing: Space.sm) {
                    Eyebrow(drill.category, accent: true)
                    Headline(drill.name, size: Typo.title)
                    Text(drill.blurb)
                        .foregroundStyle(Theme.muted)
                        .lineSpacing(Space.xxs)

                    SectionHead("Coaching cues")
                        .padding(.top, Space.xs)
                    VStack(alignment: .leading, spacing: Space.xs) {
                        ForEach(drill.cues, id: \.self) { cue in
                            BulletLine(text: cue)
                        }
                    }

                    SectionHead("Target ranges")
                        .padding(.top, Space.xs)
                    HStack {
                        Eyebrow("Metric")
                        Spacer()
                        Eyebrow("Target")
                    }
                    .padding(.top, Space.xs)
                    ForEach(drill.metrics, id: \.key) { metric in
                        VStack(spacing: 0) {
                            HStack(alignment: .firstTextBaseline, spacing: Space.sm) {
                                Text(metric.label)
                                    .foregroundStyle(Theme.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(formatNumber(metric.min))-\(formatNumber(metric.max))\(metric.unit)")
                                    .foregroundStyle(Theme.neon)
                            }
                            .font(Typo.font(Typo.label))
                            .padding(.vertical, Space.sm)
                            Rule(weight: 1, color: Theme.line)
                        }
                    }
                }
                .card()
            }
        }
    }
}
