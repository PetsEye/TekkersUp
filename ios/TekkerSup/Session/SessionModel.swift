import AVFoundation
import Foundation
import SwiftUI

private let shotMatchMs = 3000.0
private let defaultAspect = 9.0 / 16.0

/// Live session state. Camera frames arrive here on the main actor after pose processing.
@MainActor
final class SessionModel: ObservableObject {
    enum Status: Equatable {
        case loading
        case ready
        case unavailable(String)
        case failed(String)
    }

    let drill: Drill
    let side: Side
    let playerName: String?
    let shotTarget: Int?

    @Published private(set) var status: Status = .loading
    @Published private(set) var live: FrameMetrics?
    @Published private(set) var reps: [RepResult] = []
    @Published private(set) var recording = false
    @Published private(set) var notice = ""
    @Published private(set) var goal: Goal?
    @Published private(set) var calibrating = false
    @Published private(set) var posts: [Point] = []
    @Published private(set) var pose: [Int: Point] = [:]
    @Published private(set) var ballBox: CGRect?
    @Published private(set) var aspect = defaultAspect

    let capture = CameraCapture()

    private let onFinish: (SessionRecord) -> Void
    private let detector: RepDetector
    private var tracker: ShotTracker?
    private var pendingShots: [Shot] = []
    private var startedAt = Date()
    private var started = false

    init(
        drill: Drill,
        side: Side,
        playerName: String?,
        shotTarget: Int?,
        onFinish: @escaping (SessionRecord) -> Void
    ) {
        self.drill = drill
        self.side = side
        self.playerName = playerName
        self.shotTarget = shotTarget
        self.onFinish = onFinish
        self.detector = RepDetector(drill: drill)
    }

    var ballModelInstalled: Bool {
        capture.ballDetector.isAvailable
    }

    var lastRep: RepResult? {
        reps.last
    }

    var lastShot: RepShot? {
        reps.last { $0.shot != nil }?.shot
    }

    func start() {
        guard !started else { return }
        started = true
        guard CameraCapture.isDeviceAvailable else {
            status = .unavailable("Camera needs a device")
            return
        }
        Task { [weak self] in
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard let self else { return }
            guard granted else {
                self.status = .failed("Camera access is off. Allow it in Settings to train.")
                return
            }
            self.capture.start { [weak self] frame in
                self?.handle(frame)
            }
            self.status = .ready
        }
    }

    func stop() {
        guard started else { return }
        capture.stop()
    }

    func toggleSet() {
        if recording {
            endSet()
            return
        }
        reps = []
        notice = ""
        pendingShots = []
        tracker = goal.map { ShotTracker(goal: $0) }
        detector.reset()
        startedAt = Date()
        recording = true
    }

    func toggleCalibration() {
        calibrating.toggle()
        posts = []
    }

    func tap(at location: CGPoint, in size: CGSize) {
        guard calibrating else { return }
        let point = AspectFill(viewSize: size, aspect: aspect).toAnalysis(location)
        posts.append(point)
        guard posts.count == 2 else { return }
        let newGoal = goalFromPosts(posts[0], posts[1])
        goal = newGoal
        tracker = ShotTracker(goal: newGoal)
        posts = []
        calibrating = false
    }

    private func handle(_ frame: FrameResult) {
        aspect = frame.aspect
        pose = frame.pose
        ballBox = frame.ballBox

        let metrics = measureFrame(frame.pose, kicking: side)
        live = metrics

        if recording, var rep = detector.push(metrics) {
            rep.t = frame.time
            reps.append(rep)
            attachShots()
        }

        if let tracker {
            let center = frame.ballBox.map { Point(x: Double($0.midX), y: Double($0.midY)) }
            if let shot = tracker.push(center, t: frame.time), recording {
                pendingShots.append(shot)
                attachShots()
            }
        }

        if let shotTarget, recording, reps.count >= shotTarget {
            endSet()
        }
    }

    private func endSet() {
        recording = false
        guard !reps.isEmpty else {
            notice = "No reps detected. Check framing and try again."
            return
        }
        onFinish(buildSession(drill: drill, side: side, startedAt: startedAt, reps: reps, playerName: playerName))
    }

    /// Attaches pending shots to the nearest strike rep within the match window.
    private func attachShots() {
        var current = reps
        var changed = false
        pendingShots = pendingShots.filter { shot in
            guard let index = current.firstIndex(where: {
                $0.shot == nil && abs(($0.t ?? 0) - shot.t) <= shotMatchMs
            }) else {
                return true
            }
            current[index].shot = RepShot(speedKmh: shot.speedKmh, onTarget: shot.onTarget)
            changed = true
            return false
        }
        if changed {
            reps = current
        }
    }
}
