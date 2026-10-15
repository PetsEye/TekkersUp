import { getDrill } from '../lib/drills';
import type { SessionRecord } from '../lib/analyzer';

interface Props {
  session: SessionRecord;
  onBack: () => void;
  onRetry: () => void;
}

function formatDuration(ms: number): string {
  const total = Math.max(0, Math.round(ms / 1000));
  return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, '0')}`;
}

export function ReportScreen({ session, onBack, onRetry }: Props) {
  const drill = getDrill(session.drillId);
  const shots = session.reps.flatMap((r) => (r.shot ? [r.shot] : []));
  const onTarget = shots.filter((s) => s.onTarget).length;
  const avgSpeed = shots.length ? shots.reduce((sum, s) => sum + s.speedKmh, 0) / shots.length : 0;

  return (
    <>
      <div className="session-top">
        <button className="btn ghost small" onClick={onBack}>
          ← Log
        </button>
        <span className="eyebrow">Report</span>
      </div>

      <span className="eyebrow accent-text">{drill.category}</span>
      <h1>{drill.name}</h1>

      <div className="stats" style={{ marginTop: 20 }}>
        <div className="accent">
          <span>Score</span>
          <strong>{session.score}</strong>
        </div>
        <div>
          <span>Reps</span>
          <strong>{session.reps.length}</strong>
        </div>
        <div>
          <span>Duration</span>
          <strong>{formatDuration(session.endedAt - session.startedAt)}</strong>
        </div>
      </div>

      {session.reps.length === 0 ? (
        <p className="card">
          No reps were detected. Check that the full body is in frame and the striking leg is visible, then try again.
        </p>
      ) : (
        <>
          <div className="section-head">
            <span>Metrics vs target</span>
          </div>
          <table className="metric-table">
            <thead>
              <tr>
                <th>Metric</th>
                <th>Avg</th>
                <th>Target</th>
                <th>In range</th>
              </tr>
            </thead>
            <tbody>
              {session.summaries.map((s) => (
                <tr key={s.key}>
                  <td>{s.label}</td>
                  <td className="mono">
                    {s.avg.toFixed(s.decimals)}
                    {s.unit}
                  </td>
                  <td className="mono accent-text">
                    {s.min}–{s.max}
                    {s.unit}
                  </td>
                  <td className="mono">{s.inRangePct}%</td>
                </tr>
              ))}
            </tbody>
          </table>

          <div className="section-head" style={{ marginTop: 24 }}>
            <span>Pointers</span>
          </div>
          {session.pointers.map((p) => (
            <p className="pointer" key={p}>
              {p}
            </p>
          ))}

          <div className="section-head" style={{ marginTop: 24 }}>
            <span>Reps</span>
          </div>
          {shots.length > 0 && (
            <>
              <div className="section-head" style={{ marginTop: 24 }}>
                <span>Shots</span>
              </div>
              <table className="metric-table">
                <tbody>
                  <tr>
                    <td>On target</td>
                    <td className="mono accent-text">
                      {onTarget} of {shots.length}
                    </td>
                  </tr>
                  <tr>
                    <td>Average speed</td>
                    <td className="mono">{Math.round(avgSpeed)} km/h</td>
                  </tr>
                  <tr>
                    <td>Fastest shot</td>
                    <td className="mono">{Math.round(Math.max(...shots.map((s) => s.speedKmh)))} km/h</td>
                  </tr>
                </tbody>
              </table>
            </>
          )}

          <div className="rep-row">
            {session.reps.map((r) => (
              <div className="rep-chip" key={r.index}>
                <span>#{r.index}</span>
                <strong className="mono">{r.score}</strong>
                {r.shot && (
                  <span className="mono">
                    {Math.round(r.shot.speedKmh)} km/h {r.shot.onTarget ? 'on target' : 'off target'}
                  </span>
                )}
              </div>
            ))}
          </div>
        </>
      )}

      <button className="btn primary block" style={{ marginTop: 28 }} onClick={onRetry}>
        Train again
      </button>
    </>
  );
}
