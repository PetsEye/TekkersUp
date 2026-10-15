import { DRILLS } from '../lib/drills';

export function LibraryScreen() {
  return (
    <>
      <header>
        <span className="eyebrow">Library / Targets</span>
        <h1>
          Drill
          <br />
          Library
        </h1>
      </header>

      {DRILLS.map((drill) => (
        <article className="card" key={drill.id}>
          <span className="eyebrow accent-text">{drill.category}</span>
          <h2>{drill.name}</h2>
          <p>{drill.blurb}</p>

          <div className="section-head" style={{ marginTop: 16 }}>
            <span>Coaching cues</span>
          </div>
          <ul className="cues">
            {drill.cues.map((cue) => (
              <li key={cue}>{cue}</li>
            ))}
          </ul>

          <div className="section-head" style={{ marginTop: 16 }}>
            <span>Target ranges</span>
          </div>
          <table className="metric-table">
            <thead>
              <tr>
                <th>Metric</th>
                <th>Target</th>
              </tr>
            </thead>
            <tbody>
              {drill.metrics.map((m) => (
                <tr key={m.key}>
                  <td>{m.label}</td>
                  <td className="mono accent-text">
                    {m.min}–{m.max}
                    {m.unit}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </article>
      ))}
    </>
  );
}
