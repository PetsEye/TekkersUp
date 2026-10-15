import { dist, type Point } from './geometry';

export const GOAL_WIDTH_M = 7.32;
export const GOAL_HEIGHT_M = 2.44;

const START_MPS = 6;
const END_MPS = 3;
const SLOW_FRAMES = 3;
const LOST_MS = 500;

export interface Goal {
  left: Point;
  right: Point;
  ground: number;
  top: number;
  pxPerMeter: number;
}

export interface Shot {
  speedKmh: number;
  onTarget: boolean;
  t: number;
}

/** Builds the goal mouth from the two post bases. Scale comes from the known 7.32 m goal width. */
export function goalFromPosts(a: Point, b: Point): Goal {
  const left = a.x <= b.x ? a : b;
  const right = a.x <= b.x ? b : a;
  const pxPerMeter = Math.max(1, right.x - left.x) / GOAL_WIDTH_M;
  const ground = (left.y + right.y) / 2;
  return { left, right, ground, top: ground - GOAL_HEIGHT_M * pxPerMeter, pxPerMeter };
}

export function inGoal(p: Point, goal: Goal): boolean {
  return p.x >= goal.left.x && p.x <= goal.right.x && p.y >= goal.top && p.y <= goal.ground;
}

/** Turns a stream of ball positions into shots: a shot starts when the ball moves fast and ends when it slows or is lost. */
export class ShotTracker {
  private last: { p: Point; t: number } | null = null;
  private moving: { peak: number; points: Point[] } | null = null;
  private slowFrames = 0;

  constructor(private readonly goal: Goal) {}

  push(p: Point | null, t: number): Shot | null {
    if (!p) {
      if (this.moving && this.last && t - this.last.t > LOST_MS) return this.finish();
      return null;
    }
    const prev = this.last;
    this.last = { p, t };
    if (!prev || t <= prev.t) return null;

    const mps = dist(p, prev.p) / this.goal.pxPerMeter / ((t - prev.t) / 1000);
    if (!this.moving) {
      if (mps >= START_MPS) {
        this.moving = { peak: mps, points: [prev.p, p] };
        this.slowFrames = 0;
      }
      return null;
    }

    this.moving.points.push(p);
    this.moving.peak = Math.max(this.moving.peak, mps);
    this.slowFrames = mps < END_MPS ? this.slowFrames + 1 : 0;
    return this.slowFrames >= SLOW_FRAMES ? this.finish() : null;
  }

  private finish(): Shot {
    const m = this.moving!;
    this.moving = null;
    this.slowFrames = 0;
    return {
      speedKmh: m.peak * 3.6,
      onTarget: m.points.some((p) => inGoal(p, this.goal)),
      t: this.last?.t ?? 0,
    };
  }
}
