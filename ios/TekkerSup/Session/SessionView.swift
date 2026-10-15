import SwiftUI

struct SessionView: View {
    @StateObject private var model: SessionModel
    let onExit: () -> Void

    init(
        drill: Drill,
        side: Side,
        playerName: String?,
        shotTarget: Int? = nil,
        onFinish: @escaping (SessionRecord) -> Void,
        onExit: @escaping () -> Void
    ) {
        _model = StateObject(wrappedValue: SessionModel(
            drill: drill,
            side: side,
            playerName: playerName,
            shotTarget: shotTarget,
            onFinish: onFinish
        ))
        self.onExit = onExit
    }

    var body: some View {
        Screen {
            HStack(alignment: .center) {
                Button("← Exit", action: onExit)
                    .buttonStyle(.tekker(.ghost, small: true))
                Spacer()
                Eyebrow(model.drill.name)
            }

            videoFrame

            if model.drill.tracksBall {
                goalBar
            }

            liveGrid

            if let rep = model.lastRep {
                Text("Last rep #\(rep.index): \(rep.score)/100")
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(rep.score >= 75 ? Theme.neon : Theme.warn)
            }
            if let shot = model.lastShot {
                Text("Last shot: \(Int(shot.speedKmh.rounded())) km/h, \(shot.onTarget ? "on target" : "off target")")
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(shot.onTarget ? Theme.neon : Theme.warn)
            }
            if !model.notice.isEmpty {
                Text(model.notice)
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.warn)
            }

            Button(model.recording ? "End set" : "Start set", action: model.toggleSet)
                .buttonStyle(.tekker(model.recording ? .danger : .primary, fullWidth: true))
                .disabled(model.status != .ready)
        }
        .onAppear { model.start() }
        .onDisappear { model.stop() }
    }

    private var videoFrame: some View {
        Color.clear
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .overlay {
                GeometryReader { geo in
                    ZStack {
                        Color.black
                        CameraPreview(session: model.capture.session)
                        SkeletonOverlay(
                            size: geo.size,
                            aspect: model.aspect,
                            pose: model.pose,
                            goal: model.goal,
                            posts: model.posts,
                            ballBox: model.ballBox
                        )
                        statusOverlay
                        recPill
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture().onEnded { value in
                            model.tap(at: value.location, in: geo.size)
                        }
                    )
                }
            }
            .clipShape(Rectangle())
            .overlay(Rectangle().strokeBorder(Theme.rule, lineWidth: 2))
    }

    @ViewBuilder
    private var statusOverlay: some View {
        switch model.status {
        case .loading:
            overlayMessage("Starting camera…", detail: nil)
        case .unavailable(let text):
            overlayMessage(text, detail: "Run TEKKERSUP on an iPhone to track your drills.")
        case .failed(let text):
            overlayMessage(text, detail: nil)
        case .ready:
            if model.live == nil {
                overlayMessage("Step back. Full body in frame.", detail: nil)
            }
        }
    }

    private func overlayMessage(_ title: String, detail: String?) -> some View {
        VStack(spacing: Space.sm) {
            Text(title)
                .font(Typo.font(Typo.body, .black))
                .textCase(.uppercase)
                .tracking(Tracking.wide)
                .multilineTextAlignment(.center)
            if let detail {
                Text(detail)
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
            }
        }
        .foregroundStyle(Theme.text)
        .padding(Space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
    }

    @ViewBuilder
    private var recPill: some View {
        if model.recording {
            Text("● REC · \(model.reps.count) reps")
                .font(Typo.font(Typo.micro, .black))
                .foregroundStyle(Color.black)
                .padding(.horizontal, Space.xs)
                .padding(.vertical, Space.xxs)
                .background(Theme.warn)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(Space.sm)
        }
    }

    private var goalBar: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            HStack(spacing: Space.sm) {
                Text(goalStatus)
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(goalButtonTitle) { model.toggleCalibration() }
                    .buttonStyle(.tekker(.ghost, small: true))
                    .disabled(model.status != .ready || model.recording)
            }
            if !model.ballModelInstalled {
                Text("Ball model not installed: shot speed and accuracy are off")
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.warn)
            }
        }
        .padding(Space.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.panel)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }

    private var goalStatus: String {
        if model.calibrating {
            return model.posts.isEmpty ? "Tap the base of the left post." : "Now tap the base of the right post."
        }
        if model.goal != nil {
            return "Goal set. Shot speed and accuracy are measured."
        }
        return "Set the goal to measure shot speed and accuracy."
    }

    private var goalButtonTitle: String {
        if model.calibrating { return "Cancel" }
        return model.goal != nil ? "Reset goal" : "Set goal"
    }

    private var liveGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)],
            spacing: 0
        ) {
            ForEach(model.drill.metrics, id: \.key) { target in
                LiveCell(target: target, value: model.live.map { liveValue($0, key: target.key) })
            }
        }
        .overlay(alignment: .top) {
            Rule(weight: 2)
        }
    }
}

private struct LiveCell: View {
    let target: MetricTarget
    let value: Double?

    private var inRange: Bool? {
        value.map { $0 >= target.min && $0 <= target.max }
    }

    private var color: Color {
        switch inRange {
        case .none: return Theme.text
        case .some(true): return Theme.neon
        case .some(false): return Theme.warn
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(target.label)
                .font(Typo.font(Typo.micro).italic())
                .foregroundStyle(Theme.muted)
            Text(value.map { formatValue($0, decimals: target.decimals, unit: target.unit) } ?? "--")
                .font(Typo.font(Typo.title))
                .foregroundStyle(color)
                .contentTransition(.numericText(value: value ?? 0))
                .lineLimit(1)
            Text("target \(formatNumber(target.min))-\(formatNumber(target.max))\(target.unit)")
                .font(Typo.font(Typo.micro))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.sm)
        .overlay(Rectangle().strokeBorder(Theme.line, lineWidth: 1))
    }
}
