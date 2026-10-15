import { DRILLS, type Drill } from '../lib/drills';
import { mean } from '../lib/geometry';
import type { SessionRecord, Side } from '../lib/analyzer';

interface Props {
  sessions: SessionRecord[];
  side: Side;
  onStart: (drillId: string) => void;
  onBattle: () => void;
}

function Thumb({ index }: { index: number }) {
  return (
    <div className={`thumb thumb-${index % 2}`} aria-hidden="true">
      <span className="thumb-ring" />
    </div>
  );
}

function DrillRow({ drill, index, side, onStart }: { drill: Drill; index: number; side: Side; onStart: (id: string) => void }) {
  return (
    <article className="drill-row">
      <Thumb index={index} />
      <div className="drill-info">
        <span className="eyebrow accent-text">{drill.category}</span>
        <h2>{drill.name}</h2>
        <div className="tags">
          <span className="tag solid">{drill.metrics.length} metrics</span>
          <span className="tag">{side === 'right' ? 'Right' : 'Left'} foot</span>
        </div>
        <button className="btn primary small" style={{ marginTop: 12 }} onClick={() => onStart(drill.id)}>
          Start drill
        </button>
      </div>
    </article>
  );
}

export function FocusScreen({ sessions, side, onStart, onBattle }: Props) {
  const avg = sessions.length ? Math.round(mean(sessions.map((s) => s.score))) : 0;
  const best = sessions.reduce((max, s) => Math.max(max, s.score), 0);

  return (
    <>
      <header className="page-head">
        <span className="eyebrow">Player / V.01</span>
        <h1>
          Training
          <br />
          Session
        </h1>
      </header>

      <div className="stats">
        <div>
          <span>Sessions</span>
          <strong>{sessions.length}</strong>
        </div>
        <div>
          <span>Avg score</span>
          <strong>{avg}</strong>
        </div>
        <div className="accent">
          <span>Best</span>
          <strong>{best}</strong>
        </div>
      </div>

      <div className="section-head">
        <span>Battle</span>
      </div>
      <div className="battle-cta">
        <p>Two players, two shots each. The app picks who has the better technique.</p>
        <button className="btn primary block" onClick={onBattle}>
          Start a battle
        </button>
      </div>

      <div className="section-head">
        <span>Current drills</span>
        <span className="mono">
          {String(DRILLS.length).padStart(2, '0')} / {String(DRILLS.length).padStart(2, '0')}
        </span>
      </div>

      {DRILLS.map((drill, i) => (
        <DrillRow key={drill.id} drill={drill} index={i} side={side} onStart={onStart} />
      ))}
    </>
  );
}
