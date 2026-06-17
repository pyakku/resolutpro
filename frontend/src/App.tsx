import { useState } from "react";
import Login from "./pages/Login";
import { clearToken, getToken, setToken } from "./lib/api";

export default function App() {
  const [token, setTokenState] = useState<string | null>(getToken());

  function handleSuccess(newToken: string) {
    setToken(newToken);
    setTokenState(newToken);
  }

  function handleLogout() {
    clearToken();
    setTokenState(null);
  }

  if (token) {
    // Placeholder until the authenticated app is built out.
    return (
      <main className="auth-shell">
        <div className="auth-card">
          <div className="brand">
            <span className="brand-mark">R</span>
            <span className="brand-name">
              resolut<span className="brand-dot">.pro</span>
            </span>
          </div>
          <h1 className="auth-title">You're signed in</h1>
          <p className="auth-subtitle">
            Authentication succeeded. The dashboard goes here next.
          </p>
          <button className="submit-btn" onClick={handleLogout}>
            Sign out
          </button>
        </div>
      </main>
    );
  }

  return <Login onSuccess={handleSuccess} />;
}
