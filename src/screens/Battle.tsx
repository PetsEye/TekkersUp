import { useState } from 'react';
import { DRILLS, getDrill } from '../lib/drills';
import type { SessionRecord, Side } from '../lib/analyzer';
import { SessionScreen } from './Session';

export const BATTLE_SHOTS = 2;

type Phase = 'setup' | 'a' | 'b' | 'result';

interface Props {
  defaultName: string;
  side: Side;
  onSave: (records: SessionRecord[]) => void;
  onExit: () => void;
}

export function BattleScreen({ defaultName, side, onSave, onExit }: Props) {
  const [phase, setPhase] = useState<Phase>('setup');
  const [drillId, setDrillId] = useState(DRILLS[0].id);
  const [nameA, setNameA] = useState(defaultName);
  const [nameB, setNameB] = useState('');
  const [recA, setRecA] = useState<SessionRecord | null>(null);
  const [recB, setRecB] = useState<SessionRecord | null>(null);
  const drill = getDrill(drillId);
  const a = nameA.trim();
  const b = nameB.trim();

  if (phase === 'setup') {
    const ready = a !== '' && b !== '' && a.toLowerCase() !== b.toLowerCase();
    return (
      <>
        <header className="page-head">
          <span className="eyebrow">Battle / {BATTLE_SHOTS} shots each</span>
          <h1>
            Head
            <br />
            to head
          </h1>
        </header>
        <p className="hint">
          Two players take turns on the same phone. Each shoots {BATTLE_SHOTS} times, and the app ranks technique by
          average rep score.
        </p>

        <div className="section-head">
          <span>Drill</span>
        </div>
        <div className="drill-picker">
          {DRILLS.map((d) => (
            <button
              key={d.id}
              className={`pick${d.id === drillId ? ' active' : ''}`}
              onClick={() => setDrillId(d.id)}
            >
              {d.name}
            </button>
          ))}
        </div>

        <div className="section-head">
          <span>Players</span>
        </div>
        <div className="stack">
          <input className="field" placeholder="Player 1" value={nameA} onChange={(e) => setNameA(e.target.value)} />
          <input className="field" placeholder="Player 2" value={nameB} onChange={(e) => setNameB(e.target.value)} />
          {a !== '' && a.toLowerCase() === b.toLowerCase() && (
            <p className="auth-error">Players need different names.</p>
          )}
        </div>

        <div className="controls stack">
          <button className="btn primary block" disabled={!ready} onClick={() => setPhase('a')}>
            Start battle
          </button>
          <button className="btn ghost block" onClick={onExit}>
            Back
          </button>
        </div>
      </>
    );
  }

  if (phase === 'a' || phase === 'b') {
    const shooter = phase === 'a' ? a : b;
    return (
      <>
        <div className="battle-banner">
          <span className="eyebrow">Shooter {phase === 'a' ? 1 : 2} of 2</span>
          <strong>
            {shooter} takes {BATTLE_SHOTS} shots
          </strong>
        </div>
        <SessionScreen
          key={phase}
          drill={drill}
          side={side}
          playerName={shooter}
          shotTarget={BATTLE_SHOTS}
          onExit={onExit}
          onFinish={(rec) => {
            if (phase === 'a') {
              setRecA(rec);
              setPhase('b');
            } else {
              setRecB(rec);
              setPhase('result');
            }
          }}
        />
      </>
    );
  }

  if (!recA || !recB) return null;
  const winner = recA.score === recB.score ? null : recA.score > recB.score ? a : b;
  const rows = [
    { name: a, rec: recA },
    { name: b, rec: recB },
  ];

  return (
    <>
      <header className="page-head">
        <span className="eyebrow">Result / {drill.name}</span>
        <h1>{winner ?? 'Draw'}</h1>
        <p className="lead">
          {winner
            ? `${winner} has the better technique over ${BATTLE_SHOTS} shots.`
            : 'Both players scored the same. Neither technique edged out the other.'}
        </p>
      </header>

      <div className="battle-grid">
        {rows.map(({ name, rec }) => (
          <div className={`battle-card${winner === name ? ' win' : ''}`} key={name}>
            <span className="eyebrow">{name}</span>
            <strong className="mono battle-score">{rec.score}</strong>
            <span className="mono battle-meta">
              {rec.reps.length} of {BATTLE_SHOTS} shots scored
            </span>
            <ul className="cues">
              {rec.pointers.slice(0, 2).map((p) => (
                <li key={p}>{p}</li>
              ))}
            </ul>
          </div>
        ))}
      </div>
      <p className="hint">Ranked by average rep score across both shooters' shots.</p>

      <div className="controls stack">
        <button
          className="btn primary block"
          onClick={() => {
            onSave([recA, recB]);
            onExit();
          }}
        >
          Save and finish
        </button>
        <button
          className="btn ghost block"
          onClick={() => {
            setRecA(null);
            setRecB(null);
            setPhase('setup');
          }}
        >
          Rematch
        </button>
      </div>
    </>
  );
}
