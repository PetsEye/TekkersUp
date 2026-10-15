import AVFoundation
import Foundation

/// Owns the back camera. Frames are analysed on a background queue and handed to the main actor.
final class CameraCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    static var isDeviceAvailable: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    let session = AVCaptureSession()
    let ballDetector = BallDetector()

    private let sessionQueue = DispatchQueue(label: "com.tekkersup.camera.session")
    private let videoQueue = DispatchQueue(label: "com.tekkersup.camera.video")
    private let poseProcessor = PoseProcessor()
    private var onFrame: (@MainActor (FrameResult) -> Void)?
    private var configured = false

    func start(onFrame: @escaping @MainActor (FrameResult) -> Void) {
        sessionQueue.async {
            self.onFrame = onFrame
            if !self.configured {
                self.configure()
            }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func configure() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: videoQueue)
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        configured = true
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let frame = poseProcessor.process(
            pixelBuffer,
            ballDetector: ballDetector,
            time: ProcessInfo.processInfo.systemUptime * 1000
        )
        guard let onFrame else { return }
        Task { @MainActor in
            onFrame(frame)
        }
    }
}
