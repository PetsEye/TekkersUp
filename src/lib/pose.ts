import { FilesetResolver, ObjectDetector, PoseLandmarker } from '@mediapipe/tasks-vision';

const WASM_URL = 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.18/wasm';
const POSE_MODEL_URL =
  'https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/pose_landmarker_full.task';
const BALL_MODEL_URL =
  'https://storage.googleapis.com/mediapipe-models/object_detector/efficientdet_lite0/float16/latest/efficientdet_lite0.tflite';

let visionPromise: ReturnType<typeof FilesetResolver.forVisionTasks> | null = null;

function loadVision() {
  visionPromise ??= FilesetResolver.forVisionTasks(WASM_URL);
  return visionPromise;
}

export async function createPoseLandmarker(): Promise<PoseLandmarker> {
  const vision = await loadVision();
  return PoseLandmarker.createFromOptions(vision, {
    baseOptions: { modelAssetPath: POSE_MODEL_URL, delegate: 'GPU' },
    runningMode: 'VIDEO',
    numPoses: 1,
  });
}

export async function createBallDetector(): Promise<ObjectDetector> {
  const vision = await loadVision();
  return ObjectDetector.createFromOptions(vision, {
    baseOptions: { modelAssetPath: BALL_MODEL_URL, delegate: 'GPU' },
    runningMode: 'VIDEO',
    scoreThreshold: 0.25,
    maxResults: 3,
    categoryAllowlist: ['sports ball'],
  });
}
