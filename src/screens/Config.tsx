import type { Config } from '../lib/storage';
import type { Side } from '../lib/analyzer';

interface Props {
  config: Config;
  onChange: (config: Config) => void;
  onClear: () => void;
  sessionCount: number;
  email: string;
  onSignOut: () => void;
}

export function ConfigScreen({ config, onChange, onClear, sessionCount, email, onSignOut }: Props) {
  const setSide = (kickingSide: Side) => onChange({ ...config, kickingSide });

  return (
    <>
      <header>
        <span className="eyebrow">Config / Setup</span>
        <h1>
          Setup
          <br />
          Config
        </h1>
      </header>

      <div className="card">
        <span className="eyebrow accent-text">Account</span>
        <p>Signed in as {email}</p>
        <button className="btn ghost block" style={{ marginTop: 14 }} onClick={onSignOut}>
          Sign out
        </button>
      </div>

      <div className="card">
        <span className="eyebrow accent-text">Kicking foot</span>
        <p>Which leg the analysis tracks as the striking leg.</p>
        <div className="seg" style={{ marginTop: 14 }}>
          <button className={config.kickingSide === 'right' ? 'active' : ''} onClick={() => setSide('right')}>
            Right
          </button>
          <button className={config.kickingSide === 'left' ? 'active' : ''} onClick={() => setSide('left')}>
            Left
          </button>
        </div>
      </div>

      <div className="card">
        <span className="eyebrow accent-text">Camera setup</span>
        <ul className="cues">
          <li>Prop the phone 2–3 m away at waist height.</li>
          <li>Film from the side so the striking leg is visible.</li>
          <li>Keep the full body in frame, head to feet.</li>
          <li>Use good light and avoid strong backlight.</li>
        </ul>
      </div>

      <div className="card">
        <span className="eyebrow accent-text">Data</span>
        <p>{sessionCount} session(s) stored on this device.</p>
        <button
          className="btn danger block"
          style={{ marginTop: 14 }}
          disabled={sessionCount === 0}
          onClick={() => {
            if (window.confirm('Delete all saved sessions on this device?')) onClear();
          }}
        >
          Clear history
        </button>
      </div>
    </>
  );
}
