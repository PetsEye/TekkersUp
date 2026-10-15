import { getDrill } from '../lib/drills';
import type { SessionRecord } from '../lib/analyzer';

interface Props {
  sessions: SessionRecord[];
  onOpen: (sessionId: string) => void;
  onDelete: (sessionId: string) => void;
}

export function HistoryScreen({ sessions, onOpen, onDelete }: Props) {
  const recent = sessions.slice(0, 12).reverse();

  return (
    <>
      <header className="page-head">
        <span className="eyebrow">Log / History</span>
        <h1>
          Session
          <br />
          Log
        </h1>
      </header>

      {sessions.length > 0 && (
        <>
          <div className="section-head">
            <span>Progress</span>
            <span className="mono">last {recent.length}</span>
          </div>
          <div className="chart">
            {recent.map((s) => (
              <div className="bar-col" key={s.id} title={`${getDrill(s.drillId).name}: ${s.score}`}>
                <span className="bar-val mono">{s.score}</span>
                <div className="bar-wrap">
                  <div className="bar" style={{ height: `${Math.max(3, s.score)}%` }} />
                </div>
              </div>
            ))}
          </div>
        </>
      )}

      <div className="section-head">
        <span>Sessions</span>
      </div>
      {sessions.length === 0 && (
        <p className="empty">No sessions yet. Start a drill from Focus to record your first set.</p>
      )}

      {sessions.map((s) => (
        <div className="list-row" key={s.id}>
          <button className="row-main" onClick={() => onOpen(s.id)}>
            <span className="eyebrow accent-text">
              {getDrill(s.drillId).name}
              {s.playerName ? ` / ${s.playerName}` : ''}
            </span>
            <span className="mono row-meta">
              {new Date(s.startedAt).toLocaleString()} / {s.reps.length} reps
            </span>
          </button>
          <strong className="mono accent-text row-score">{s.score}</strong>
          <button
            className="btn ghost small"
            onClick={() => {
              if (window.confirm('Delete this session?')) onDelete(s.id);
            }}
          >
            Delete
          </button>
        </div>
      ))}
    </>
  );
}
