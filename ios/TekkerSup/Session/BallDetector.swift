import CoreML
import Foundation
import Vision

/// Finds the ball with a bundled CoreML model named SportsBall.mlmodelc.
/// Without the model it reports isAvailable = false and detects nothing.
final class BallDetector {
    static let label = "sports ball"

    private let request: VNCoreMLRequest?

    var isAvailable: Bool {
        request != nil
    }

    init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "SportsBall", withExtension: "mlmodelc"),
              let model = try? MLModel(contentsOf: url),
              let visionModel = try? VNCoreMLModel(for: model) else {
            request = nil
            return
        }
        let request = VNCoreMLRequest(model: visionModel)
        request.imageCropAndScaleOption = .scaleFill
        self.request = request
    }

    /// Returns the best "sports ball" bounding box in Vision's normalized space (bottom-left origin).
    func detect(in handler: VNImageRequestHandler) -> CGRect? {
        guard let request else { return nil }
        try? handler.perform([request])
        let observations = request.results as? [VNRecognizedObjectObservation] ?? []
        return observations
            .filter { observation in observation.labels.contains { $0.identifier == Self.label } }
            .max { $0.confidence < $1.confidence }?
            .boundingBox
    }
}
