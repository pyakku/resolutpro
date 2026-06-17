import { useState, type FormEvent } from "react";
import { ApiError, login } from "../lib/api";

interface LoginProps {
  onSuccess: (token: string) => void;
}

export default function Login({ onSuccess }: LoginProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);

    if (!email.trim() || !password) {
      setError("Please enter your email and password.");
      return;
    }

    setSubmitting(true);
    try {
      const token = await login(email.trim(), password);
      onSuccess(token);
    } catch (err) {
      setError(
        err instanceof ApiError ? err.message : "Something went wrong."
      );
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-shell">
      <form className="auth-card" onSubmit={handleSubmit} noValidate>
        <div className="brand">
          <span className="brand-mark">R</span>
          <span className="brand-name">resolut<span className="brand-dot">.pro</span></span>
        </div>

        <h1 className="auth-title">Sign in</h1>
        <p className="auth-subtitle">Welcome back. Please enter your details.</p>

        {error && (
          <div className="auth-error" role="alert">
            {error}
          </div>
        )}

        <label className="field">
          <span className="field-label">Email</span>
          <input
            type="email"
            name="email"
            autoComplete="email"
            placeholder="you@company.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={submitting}
            required
          />
        </label>

        <label className="field">
          <span className="field-label">Password</span>
          <div className="password-wrap">
            <input
              type={showPassword ? "text" : "password"}
              name="password"
              autoComplete="current-password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={submitting}
              required
            />
            <button
              type="button"
              className="password-toggle"
              onClick={() => setShowPassword((s) => !s)}
              tabIndex={-1}
              aria-label={showPassword ? "Hide password" : "Show password"}
            >
              {showPassword ? "Hide" : "Show"}
            </button>
          </div>
        </label>

        <button type="submit" className="submit-btn" disabled={submitting}>
          {submitting ? "Signing in…" : "Sign in"}
        </button>
      </form>

      <p className="auth-footer">© 2026 resolut.pro</p>
    </main>
  );
}
