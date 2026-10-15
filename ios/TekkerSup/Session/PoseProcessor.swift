import CoreVideo
import Foundation
import Vision

struct FrameResult: Sendable {
    /// Joints keyed by MediaPipe-style index, in analysis space (x scaled by aspect, y down from top).
    var pose: [Int: Point]
    var ballBox: CGRect?
    var aspect: Double
    /// Milliseconds on the monotonic clock.
    var time: Double
}

/// Runs Vision pose detection on each frame. Used from the video queue.
final class PoseProcessor {
    private static let minConfidence: Float = 0.5
    private static let joints: [(VNHumanBodyPoseObservation.JointName, Int)] = [
        (.leftShoulder, 11), (.rightShoulder, 12),
        (.leftElbow, 13), (.rightElbow, 14),
        (.leftWrist, 15), (.rightWrist, 16),
        (.leftHip, 23), (.rightHip, 24),
        (.leftKnee, 25), (.rightKnee, 26),
        (.leftAnkle, 27), (.rightAnkle, 28),
    ]

    private let request = VNDetectHumanBodyPoseRequest()

    func process(_ buffer: CVPixelBuffer, ballDetector: BallDetector, time: Double) -> FrameResult {
        let width = Double(CVPixelBufferGetWidth(buffer))
        let height = Double(CVPixelBufferGetHeight(buffer))
        let aspect = height / width
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .right, options: [:])

        try? handler.perform([request])

        var pose: [Int: Point] = [:]
        if let observation = request.results?.first as? VNHumanBodyPoseObservation,
           let points = try? observation.recognizedPoints(.all) {
            for (joint, index) in Self.joints {
                guard let point = points[joint], point.confidence >= Self.minConfidence else { continue }
                pose[index] = Point(
                    x: Double(point.location.x) * aspect,
                    y: 1 - Double(point.location.y)
                )
            }
        }

        var ballBox: CGRect?
        if let box = ballDetector.detect(in: handler) {
            let a = CGFloat(aspect)
            ballBox = CGRect(
                x: box.minX * a,
                y: 1 - box.maxY,
                width: box.width * a,
                height: box.height
            )
        }

        return FrameResult(pose: pose, ballBox: ballBox, aspect: aspect, time: time)
    }
}
