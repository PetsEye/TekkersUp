import { useState, type FormEvent } from 'react';
import { login, register } from '../lib/auth';

interface Props {
  mode: 'login' | 'register';
  onSwitch: (mode: 'login' | 'register') => void;
  onBack: () => void;
  onDone: (email: string) => void;
}

export function AuthForm({ mode, onSwitch, onBack, onDone }: Props) {
  const isRegister = mode === 'register';
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [agreed, setAgreed] = useState(false);
  const [updates, setUpdates] = useState(false);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    if (!/^\S+@\S+\.\S+$/.test(email.trim())) return setError('Enter a valid email address.');
    if (password.length < 6) return setError('Password must be at least 6 characters.');
    if (isRegister) {
      if (password !== confirm) return setError('Passwords do not match.');
      if (!agreed) return setError('Please agree to the Terms & Privacy Policy.');
    }
    setBusy(true);
    const result = isRegister ? await register(email, password) : await login(email, password);
    setBusy(false);
    if (result) return setError(result);
    onDone(email.trim().toLowerCase());
  };

  return (
    <form className="auth-form" onSubmit={submit} noValidate>
      <button type="button" className="btn ghost small back" onClick={onBack}>
        ← Back
      </button>
      <div className="brand">TEKKERSUP</div>
      <h2 className="auth-title">{isRegister ? 'Create an Account' : 'Welcome Back'}</h2>
      <p className="auth-sub">
        {isRegister
          ? 'To create an account, enter your email and set a password.'
          : 'Log in with your email and password to continue.'}
      </p>

      <input
        className="field"
        type="email"
        placeholder="Email address"
        autoComplete="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <div className="field-wrap">
        <input
          className="field"
          type={showPassword ? 'text' : 'password'}
          placeholder="Password"
          autoComplete={isRegister ? 'new-password' : 'current-password'}
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button type="button" className="eye" onClick={() => setShowPassword((v) => !v)} aria-label="Toggle password">
          {showPassword ? 'Hide' : 'Show'}
        </button>
      </div>
      {isRegister && (
        <input
          className="field"
          type={showPassword ? 'text' : 'password'}
          placeholder="Confirm Password"
          autoComplete="new-password"
          value={confirm}
          onChange={(e) => setConfirm(e.target.value)}
        />
      )}

      {error && <p className="auth-error">{error}</p>}

      <button className="btn primary block" type="submit" disabled={busy}>
        {busy ? 'Please wait…' : isRegister ? 'Continue' : 'Log In'}
      </button>

      <div className="auth-or">Or</div>
      <div className="social-row">
        <button type="button" className="btn ghost" disabled title="Coming soon">
          Google
        </button>
        <button type="button" className="btn ghost" disabled title="Coming soon">
          Apple
        </button>
      </div>

      {isRegister && (
        <div className="checks">
          <label>
            <input type="checkbox" checked={agreed} onChange={(e) => setAgreed(e.target.checked)} />
            I agree to the Terms &amp; Privacy Policy
          </label>
          <label>
            <input type="checkbox" checked={updates} onChange={(e) => setUpdates(e.target.checked)} />
            Send me updates &amp; news
          </label>
        </div>
      )}

      <p className="auth-switch">
        {isRegister ? 'Already have an account? ' : "Don't have an account? "}
        <button type="button" className="link" onClick={() => onSwitch(isRegister ? 'login' : 'register')}>
          {isRegister ? 'Log In' : 'Register'}
        </button>
      </p>
    </form>
  );
}
