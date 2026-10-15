interface Props {
  onLogin: () => void;
  onRegister: () => void;
  onAbout: () => void;
}

export function WelcomeScreen({ onLogin, onRegister, onAbout }: Props) {
  return (
    <div className="auth-welcome">
      <div className="brand">TEKKERSUP</div>
      <div className="hero">
        <h1>
          Start Your
          <br />
          Training <em>Today!</em>
        </h1>
        <p>Simple drills to sharpen your technique, power and balance. Check your form with your phone.</p>
      </div>
      <div className="auth-actions">
        <button className="btn ghost block" onClick={onLogin}>
          Play Now
        </button>
        <button className="btn primary block" onClick={onRegister}>
          Register Now
        </button>
      </div>
      <button className="btn ghost block" onClick={onAbout}>
        How TEKKERSUP works
      </button>
    </div>
  );
}
