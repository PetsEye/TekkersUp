import { angleDeg, dist, mean, midpoint, type Point } from './geometry';
import type { Drill, MetricKey } from './drills';

export type Side = 'right' | 'left';

export interface PoseLandmark {
  x: number;
  y: number;
  visibility?: number;
}

export interface FrameMetrics {
  kick: number;
  support: number;
  lean: number;
  armSpread: number;
}

export interface RepResult {
  index: number;
  values: Record<MetricKey, number>;
  passed: Partial<Record<MetricKey, boolean>>;
  score: number;
  t?: number;
  shot?: { speedKmh: number; onTarget: boolean };
}

export interface MetricSummary {
  key: MetricKey;
  label: string;
  unit: string;
  decimals: number;
  min: number;
  max: number;
  avg: number;
  inRangePct: number;
}

export interface SessionRecord {
  id: string;
  drillId: string;
  side: Side;
  startedAt: number;
  endedAt: number;
  reps: RepResult[];
  score: number;
  summaries: MetricSummary[];
  pointers: string[];
  playerName?: string;
}

const JOINTS = {
  L: { shoulder: 11, hip: 23, knee: 25, ankle: 27, wrist: 15 },
  R: { shoulder: 12, hip: 24, knee: 26, ankle: 28, wrist: 16 },
};

const MIN_VISIBILITY = 0.5;
const MAX_CONCERN_PCT = 70;
const MAX_CYCLE_FRAMES = 300;

/**
 * Measures posture metrics for one frame. Coordinates are scaled by the video
 * aspect ratio so angles are not distorted on non-square frames.
 */
export function measureFrame(lm: PoseLandmark[], kicking: Side, aspect: number): FrameMetrics | null {
  const K = kicking === 'right' ? JOINTS.R : JOINTS.L;
  const S = kicking === 'right' ? JOINTS.L : JOINTS.R;
  const required = [K.hip, K.knee, K.ankle, S.hip, S.knee, S.ankle, 11, 12, 23, 24, 15, 16];
  if (required.some((i) => !lm[i] || (lm[i].visibility ?? 0) < MIN_VISIBILITY)) return null;

  const pt = (i: number): Point => ({ x: lm[i].x * aspect, y: lm[i].y });
  const shoulderMid = midpoint(pt(11), pt(12));
  const hipMid = midpoint(pt(23), pt(24));
  const lean =
    (Math.atan2(Math.abs(shoulderMid.x - hipMid.x), Math.abs(shoulderMid.y - hipMid.y)) * 180) / Math.PI;
  const shoulderWidth = dist(pt(11), pt(12));

  return {
    kick: angleDeg(pt(K.hip), pt(K.knee), pt(K.ankle)),
    support: angleDeg(pt(S.hip), pt(S.knee), pt(S.ankle)),
    lean,
    armSpread: shoulderWidth > 0 ? dist(pt(15), pt(16)) / shoulderWidth : 0,
  };
}

export function liveValue(m: FrameMetrics, key: MetricKey): number {
  switch (key) {
    case 'backswing':
      return m.kick;
    case 'support':
      return m.support;
    case 'lean':
      return m.lean;
    case 'arms':
      return m.armSpread;
  }
}

function evaluateRep(drill: Drill, index: number, values: Record<MetricKey, number>): RepResult {
  const passed: Partial<Record<MetricKey, boolean>> = {};
  let hits = 0;
  for (const t of drill.metrics) {
    const ok = values[t.key] >= t.min && values[t.key] <= t.max;
    passed[t.key] = ok;
    if (ok) hits++;
  }
  return { index, values, passed, score: Math.round((hits / drill.metrics.length) * 100) };
}

/** Detects strike cycles: cock the kicking leg (knee below cockAngle), then extend past extendAngle. */
export class RepDetector {
  private cocked = false;
  private samples: FrameMetrics[] = [];
  private minKick = Infinity;
  private count = 0;

  constructor(private readonly drill: Drill) {}

  reset(): void {
    this.cocked = false;
    this.samples = [];
    this.minKick = Infinity;
    this.count = 0;
  }

  push(m: FrameMetrics | null): RepResult | null {
    if (!m) return null;

    if (!this.cocked) {
      if (m.kick < this.drill.cockAngle) {
        this.cocked = true;
        this.samples = [m];
        this.minKick = m.kick;
      }
      return null;
    }

    if (m.kick > this.drill.extendAngle) {
      const values: Record<MetricKey, number> = {
        backswing: this.minKick,
        support: m.support,
        lean: mean(this.samples.map((s) => s.lean)),
        arms: mean(this.samples.map((s) => s.armSpread)),
      };
      this.cocked = false;
      this.samples = [];
      this.count++;
      return evaluateRep(this.drill, this.count, values);
    }

    this.samples.push(m);
    this.minKick = Math.min(this.minKick, m.kick);
    if (this.samples.length > MAX_CYCLE_FRAMES) {
      this.cocked = false;
      this.samples = [];
    }
    return null;
  }
}

export function buildSession(drill: Drill, side: Side, startedAt: number, reps: RepResult[]): SessionRecord {
  const summaries: MetricSummary[] = drill.metrics.map((t) => {
    const vals = reps.map((r) => r.values[t.key]);
    const inRange = reps.filter((r) => r.passed[t.key]).length;
    return {
      key: t.key,
      label: t.label,
      unit: t.unit,
      decimals: t.decimals,
      min: t.min,
      max: t.max,
      avg: mean(vals),
      inRangePct: reps.length ? Math.round((inRange / reps.length) * 100) : 0,
    };
  });

  const pointers: string[] = [];
  if (reps.length) {
    drill.metrics.forEach((t, i) => {
      const s = summaries[i];
      if (s.inRangePct >= MAX_CONCERN_PCT) return;
      const tip = s.avg < t.min ? t.tipLow : t.tipHigh;
      pointers.push(`${t.label}: ${tip}`);
    });
    if (pointers.length === 0) {
      pointers.push('Solid, consistent form across the set. Next step: add speed and reps under pressure.');
    }
  }

  return {
    id: `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`,
    drillId: drill.id,
    side,
    startedAt,
    endedAt: Date.now(),
    reps,
    score: reps.length ? Math.round(mean(reps.map((r) => r.score))) : 0,
    summaries,
    pointers,
  };
}
