export type MetricKey = 'backswing' | 'support' | 'lean' | 'arms';

export interface MetricTarget {
  key: MetricKey;
  label: string;
  min: number;
  max: number;
  unit: string;
  decimals: number;
  tipLow: string;
  tipHigh: string;
}

export interface Drill {
  id: string;
  name: string;
  category: string;
  blurb: string;
  /** Kicking knee angle (degrees) below which the leg is considered cocked back. */
  cockAngle: number;
  /** Kicking knee angle (degrees) above which the strike/contact is considered complete. */
  extendAngle: number;
  cues: string[];
  metrics: MetricTarget[];
  /** Tracks the ball and goal for shot speed and accuracy. */
  tracksBall?: boolean;
}

export const DRILLS: Drill[] = [
  {
    id: 'power-shot',
    tracksBall: true,
    name: 'Power Shot',
    category: 'Shooting / Power',
    blurb: 'Load the kicking leg, swing through the ball, and plant firmly. Measures backswing depth, base stability and balance.',
    cockAngle: 120,
    extendAngle: 150,
    cues: [
      'Plant foot beside the ball, slightly behind it.',
      'Bring the kicking heel back toward the glute to load the leg.',
      'Keep the chest over the ball and the head down.',
      'Open the arms for counterbalance through the strike.',
    ],
    metrics: [
      {
        key: 'backswing',
        label: 'Backswing knee bend',
        min: 60,
        max: 100,
        unit: '°',
        decimals: 0,
        tipLow: 'Heel is tucked too tight. Open the hip slightly so the leg can swing through with full extension.',
        tipHigh: 'Not enough cock. Bring the kicking heel back toward your glute to load more power.',
      },
      {
        key: 'support',
        label: 'Plant knee at contact',
        min: 150,
        max: 175,
        unit: '°',
        decimals: 0,
        tipLow: 'Plant knee is sinking too far. Stand taller over the ball for a stable base.',
        tipHigh: 'Plant knee is locked straight. Keep a slight bend so you stay balanced.',
      },
      {
        key: 'lean',
        label: 'Torso lean',
        min: 0,
        max: 15,
        unit: '°',
        decimals: 0,
        tipLow: 'Torso lean is off in the other direction. Stay balanced over your base.',
        tipHigh: 'Leaning too far back or forward. Keep the chest over the ball and the head down.',
      },
      {
        key: 'arms',
        label: 'Arm balance (wrist spread)',
        min: 1.0,
        max: 2.5,
        unit: 'x',
        decimals: 2,
        tipLow: 'Arms are tucked in. Open them out to counterbalance the swing.',
        tipHigh: 'Arms are flailing wide. Keep them under control to stay balanced.',
      },
    ],
  },
  {
    id: 'inside-pass',
    tracksBall: true,
    name: 'Inside-Foot Pass',
    category: 'Passing / Technique',
    blurb: 'Short, controlled pass with the inside of the foot. Checks a smaller backswing, a balanced plant and an upright posture.',
    cockAngle: 150,
    extendAngle: 165,
    cues: [
      'Open the hips so the non-kicking foot points at the target.',
      'Small backswing: the kicking foot only moves a short distance.',
      'Strike through the centre of the ball with the inside of the foot.',
      'Stay tall through the pass and keep the arms relaxed.',
    ],
    metrics: [
      {
        key: 'backswing',
        label: 'Backswing knee bend',
        min: 110,
        max: 140,
        unit: '°',
        decimals: 0,
        tipLow: 'Backswing is too big for a controlled pass. Shorten the leg swing.',
        tipHigh: 'Backswing is too small. Let the knee bend a little more before the strike.',
      },
      {
        key: 'support',
        label: 'Plant knee at contact',
        min: 145,
        max: 170,
        unit: '°',
        decimals: 0,
        tipLow: 'Plant knee is sinking too far. Stand taller over the ball.',
        tipHigh: 'Plant knee is locked. Keep a soft bend for balance and touch.',
      },
      {
        key: 'lean',
        label: 'Torso lean',
        min: 0,
        max: 12,
        unit: '°',
        decimals: 0,
        tipLow: 'Torso lean is off in the other direction. Stay balanced.',
        tipHigh: 'Leaning too much. Keep the body upright for accurate passes.',
      },
      {
        key: 'arms',
        label: 'Arm balance (wrist spread)',
        min: 0.8,
        max: 2.0,
        unit: 'x',
        decimals: 2,
        tipLow: 'Arms are pinned to the body. Let them move naturally for balance.',
        tipHigh: 'Arms are too wide for a passing motion. Bring them in closer.',
      },
    ],
  },
];

export function getDrill(id: string): Drill {
  const drill = DRILLS.find((d) => d.id === id);
  if (!drill) throw new Error(`Unknown drill: ${id}`);
  return drill;
}
