import { useEffect, useRef, useState, type MouseEvent } from 'react';
import type { NormalizedLandmark, ObjectDetector, PoseLandmarker } from '@mediapipe/tasks-vision';
import { buildSession, liveValue, measureFrame, RepDetector, type FrameMetrics, type RepResult, type Side, type SessionRecord } from '../lib/analyzer';
import type { Drill } from '../lib/drills';
import { createBallDetector, createPoseLandmarker } from '../lib/pose';
import { goalFromPosts, ShotTracker, type Goal, type Shot } from '../lib/ball';
import type { Point } from '../lib/geometry';

const BONES: [number, number][] = [
  [11, 12], [11, 23], [12, 24], [23, 24], [23, 25], [25, 27], [24, 26], [26, 28],
  [11, 13], [13, 15], [12, 14], [14, 16],
];
const NEON = '#c6ff3d';
const WARN = '#ff5d5d';
const SHOT_MATCH_MS = 3000;

interface Props {
  drill: Drill;
  side: Side;
  playerName?: string;
  shotTarget?: number;
  onFinish: (session: SessionRecord) => void;
  onExit: () => void;
}

function drawSkeleton(ctx: CanvasRenderingContext2D, lm: NormalizedLandmark[], w: number, h: number) {
  ctx.lineWidth = Math.max(2, w / 240);
  ctx.strokeStyle = NEON;
  ctx.fillStyle = NEON;
  const visible = (p: NormalizedLandmark | undefined) => !!p && (p.visibility ?? 0) >= 0.5;
  for (const [a, b] of BONES) {
    const p = lm[a];
    const q = lm[b];
    if (!visible(p) || !visible(q)) continue;
    ctx.beginPath();
    ctx.moveTo(p.x * w, p.y * h);
    ctx.lineTo(q.x * w, q.y * h);
    ctx.stroke();
  }
  for (const p of lm) {
    if (!visible(p)) continue;
    ctx.beginPath();
    ctx.arc(p.x * w, p.y * h, Math.max(3, w / 200), 0, Math.PI * 2);
    ctx.fill();
  }
}

function drawGoal(ctx: CanvasRenderingContext2D, goal: Goal, w: number) {
  ctx.save();
  ctx.strokeStyle = NEON;
  ctx.lineWidth = Math.max(2, w / 240);
  ctx.setLineDash([8, 6]);
  ctx.strokeRect(goal.left.x, goal.top, goal.right.x - goal.left.x, goal.ground - goal.top);
  ctx.restore();
}

function drawBall(ctx: CanvasRenderingContext2D, box: { originX: number; originY: number; width: number; height: number }, w: number) {
  ctx.save();
  ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = Math.max(2, w / 240);
  ctx.strokeRect(box.originX, box.originY, box.width, box.height);
  ctx.restore();
}

export function SessionScreen({ drill, side, playerName, shotTarget, onFinish, onExit }: Props) {
  const finishRef = useRef(onFinish);
  finishRef.current = onFinish;
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const detectorRef = useRef<RepDetector | null>(null);
  const recordingRef = useRef(false);
  const repsRef = useRef<RepResult[]>([]);
  const startedRef = useRef(0);
  const goalRef = useRef<Goal | null>(null);
  const trackerRef = useRef<ShotTracker | null>(null);
  const pendingShotsRef = useRef<Shot[]>([]);

  const [status, setStatus] = useState<'loading' | 'ready' | 'error'>('loading');
  const [error, setError] = useState('');
  const [recording, setRecording] = useState(false);
  const [live, setLive] = useState<FrameMetrics | null>(null);
  const [reps, setReps] = useState<RepResult[]>([]);
  const [notice, setNotice] = useState('');
  const [goal, setGoal] = useState<Goal | null>(null);
  const [calibrating, setCalibrating] = useState(false);
  const [posts, setPosts] = useState<Point[]>([]);

  const attachShots = () => {
    let current = repsRef.current;
    let changed = false;
    pendingShotsRef.current = pendingShotsRef.current.filter((shot) => {
      const idx = current.findIndex((r) => !r.shot && Math.abs((r.t ?? 0) - shot.t) <= SHOT_MATCH_MS);
      if (idx < 0) return true;
      current = current.map((r, i) =>
        i === idx ? { ...r, shot: { speedKmh: shot.speedKmh, onTarget: shot.onTarget } } : r,
      );
      changed = true;
      return false;
    });
    if (changed) {
      repsRef.current = current;
      setReps(current);
    }
  };

  useEffect(() => {
    let stopped = false;
    let raf = 0;
    let stream: MediaStream | null = null;
    let landmarker: PoseLandmarker | null = null;
    let ball: ObjectDetector | null = null;
    let lastVideoTime = -1;
    let lastUiUpdate = 0;

    const detector = new RepDetector(drill);
    detectorRef.current = detector;

    const loop = () => {
      if (stopped) return;
      const video = videoRef.current;
      const canvas = canvasRef.current;
      if (video && canvas && landmarker && video.readyState >= 2 && video.currentTime !== lastVideoTime) {
        lastVideoTime = video.currentTime;
        if (canvas.width !== video.videoWidth) {
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;
        }
        const result = landmarker.detectForVideo(video, performance.now());
        const lm = result.landmarks[0];
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.clearRect(0, 0, canvas.width, canvas.height);
          if (lm) drawSkeleton(ctx, lm, canvas.width, canvas.height);
          if (goalRef.current) drawGoal(ctx, goalRef.current, canvas.width);
        }

        const aspect = video.videoWidth / video.videoHeight;
        const metrics = lm ? measureFrame(lm, side, aspect) : null;

        if (recordingRef.current) {
          const rep = detector.push(metrics);
          if (rep) {
            repsRef.current = [...repsRef.current, { ...rep, t: performance.now() }];
            setReps(repsRef.current);
            attachShots();
          }
        }

        if (ball && ctx && goalRef.current && trackerRef.current) {
          const detections = ball.detectForVideo(video, performance.now()).detections;
          const top = [...detections].sort((x, y) => (y.categories[0]?.score ?? 0) - (x.categories[0]?.score ?? 0))[0];
          const box = top?.boundingBox;
          if (box) drawBall(ctx, box, canvas.width);
          const center = box ? { x: box.originX + box.width / 2, y: box.originY + box.height / 2 } : null;
          const shot = trackerRef.current.push(center, performance.now());
          if (shot && recordingRef.current) {
            pendingShotsRef.current.push(shot);
            attachShots();
          }
        }

        if (shotTarget && recordingRef.current && repsRef.current.length >= shotTarget) {
          recordingRef.current = false;
          setRecording(false);
          finishRef.current({
            ...buildSession(drill, side, startedRef.current, repsRef.current),
            playerName,
          });
        }

        const now = performance.now();
        if (now - lastUiUpdate > 120) {
          lastUiUpdate = now;
          setLive(metrics);
        }
      }
      raf = requestAnimationFrame(loop);
    };

    (async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: { ideal: 'environment' }, width: { ideal: 1280 }, height: { ideal: 720 } },
          audio: false,
        });
        if (stopped) {
          stream.getTracks().forEach((t) => t.stop());
          return;
        }
        const video = videoRef.current;
        if (!video) return;
        video.srcObject = stream;
        await video.play();
        landmarker = await createPoseLandmarker();
        if (drill.tracksBall) ball = await createBallDetector();
        if (stopped) {
          landmarker?.close();
          ball?.close();
          return;
        }
        setStatus('ready');
        raf = requestAnimationFrame(loop);
      } catch (e) {
        if (!stopped) {
          setError(e instanceof Error ? e.message : 'Could not start the camera.');
          setStatus('error');
        }
      }
    })();

    return () => {
      stopped = true;
      cancelAnimationFrame(raf);
      stream?.getTracks().forEach((t) => t.stop());
      landmarker?.close();
      ball?.close();
      landmarker = null;
      ball = null;
    };
  }, [drill, side, playerName, shotTarget]);

  const onVideoTap = (e: MouseEvent<HTMLDivElement>) => {
    const video = videoRef.current;
    if (!calibrating || !video || !video.videoWidth) return;
    const rect = e.currentTarget.getBoundingClientRect();
    const scale = Math.max(rect.width / video.videoWidth, rect.height / video.videoHeight);
    const x = (e.clientX - rect.left - (rect.width - video.videoWidth * scale) / 2) / scale;
    const y = (e.clientY - rect.top - (rect.height - video.videoHeight * scale) / 2) / scale;
    const next = [...posts, { x, y }];
    if (next.length < 2) {
      setPosts(next);
      return;
    }
    const g = goalFromPosts(next[0], next[1]);
    goalRef.current = g;
    trackerRef.current = new ShotTracker(g);
    setGoal(g);
    setPosts([]);
    setCalibrating(false);
  };

  const toggleSet = () => {
    if (!recording) {
      repsRef.current = [];
      setReps([]);
      setNotice('');
      pendingShotsRef.current = [];
      trackerRef.current = goalRef.current ? new ShotTracker(goalRef.current) : null;
      detectorRef.current?.reset();
      startedRef.current = Date.now();
      recordingRef.current = true;
      setRecording(true);
      return;
    }
    recordingRef.current = false;
    setRecording(false);
    if (repsRef.current.length === 0) {
      setNotice('No reps detected. Check framing and try again.');
      return;
    }
    finishRef.current({ ...buildSession(drill, side, startedRef.current, repsRef.current), playerName });
  };

  const lastRep = reps[reps.length - 1];
  const lastShot = [...reps].reverse().find((r) => r.shot)?.shot;

  return (
    <>
      <div className="session-top">
        <button className="btn ghost small" onClick={onExit}>
          ← Exit
        </button>
        <span className="eyebrow">{drill.name}</span>
      </div>

      <div className="video-wrap" onClick={onVideoTap}>
        <video ref={videoRef} playsInline muted />
        <canvas ref={canvasRef} className="overlay" />
        {status === 'loading' && <div className="overlay-msg">Loading pose model…</div>}
        {status === 'error' && <div className="overlay-msg">{error}</div>}
        {status === 'ready' && !live && <div className="overlay-msg small">Step back. Full body in frame.</div>}
        {recording && <span className="rec-pill">● REC · {reps.length} reps</span>}
      </div>

      {drill.tracksBall && (
        <div className="goal-bar">
          <span className="goal-status">
            {calibrating
              ? posts.length === 0
                ? 'Tap the base of the left post.'
                : 'Now tap the base of the right post.'
              : goal
                ? 'Goal set. Shot speed and accuracy are measured.'
                : 'Set the goal to measure shot speed and accuracy.'}
          </span>
          <button
            className="btn ghost small"
            disabled={status !== 'ready' || recording}
            onClick={() => {
              setCalibrating((c) => !c);
              setPosts([]);
            }}
          >
            {calibrating ? 'Cancel' : goal ? 'Reset goal' : 'Set goal'}
          </button>
        </div>
      )}

      <div className="live-grid">
        {drill.metrics.map((t) => {
          const v = live ? liveValue(live, t.key) : null;
          const ok = v !== null && v >= t.min && v <= t.max;
          return (
            <div className={`live-cell${v === null ? '' : ok ? ' ok' : ' bad'}`} key={t.key}>
              <span>{t.label}</span>
              <strong>
                {v === null ? '--' : v.toFixed(t.decimals)}
                {v === null ? '' : t.unit}
              </strong>
              <span className="mono">
                target {t.min}–{t.max}
                {t.unit}
              </span>
            </div>
          );
        })}
      </div>

      {lastRep && (
        <p className="hint" style={{ color: lastRep.score >= 75 ? NEON : WARN }}>
          Last rep #{lastRep.index}: {lastRep.score}/100
        </p>
      )}
      {lastShot && (
        <p className="hint" style={{ color: lastShot.onTarget ? NEON : WARN }}>
          Last shot: {Math.round(lastShot.speedKmh)} km/h, {lastShot.onTarget ? 'on target' : 'off target'}
        </p>
      )}
      {notice && (
        <p className="hint" style={{ color: WARN }}>
          {notice}
        </p>
      )}

      <div className="controls">
        <button className={`btn block ${recording ? 'danger' : 'primary'}`} disabled={status !== 'ready'} onClick={toggleSet}>
          {recording ? 'End set' : 'Start set'}
        </button>
      </div>
    </>
  );
}
