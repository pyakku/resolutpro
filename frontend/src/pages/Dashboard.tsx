import { Navigate, useNavigate } from "react-router-dom";
import { useAuthStore } from "../store/auth";
import { LOGO } from "../lib/brand";

export default function Dashboard() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);
  const company = useAuthStore((s) => s.selectedCompany);
  const selectCompany = useAuthStore((s) => s.selectCompany);
  const logout = useAuthStore((s) => s.logout);

  // No company chosen yet — send the user back to the picker.
  if (!company) {
    return <Navigate to="/select-company" replace />;
  }

  function switchCompany() {
    selectCompany(null);
    navigate("/select-company", { replace: true });
  }

  function handleLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  return (
    <main className="min-h-screen bg-slate-50">
      <header className="bg-brand-dark">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 h-16 flex items-center justify-between">
          <img src={LOGO.proWhite} alt="Resolut.Pro" className="h-7 w-auto" />
          <div className="flex items-center gap-4">
            <span className="hidden sm:inline text-sm text-slate-300">
              {company.Company_Name}
            </span>
            <button
              onClick={switchCompany}
              className="text-sm text-slate-300 hover:text-white"
            >
              Switch company
            </button>
            <button
              onClick={handleLogout}
              className="text-sm text-slate-300 hover:text-white"
            >
              Log out
            </button>
          </div>
        </div>
      </header>

      <section className="mx-auto max-w-6xl px-4 sm:px-6 py-10">
        <h1 className="text-2xl font-semibold text-brand-dark">
          {company.Company_Name ?? "Dashboard"}
        </h1>
        <p className="mt-1 text-sm text-slate-500">
          Signed in as {user?.email ?? "your account"}.
        </p>

        <div className="mt-8 rounded-xl border border-dashed border-slate-300 bg-white p-12 text-center">
          <p className="text-sm font-medium text-slate-600">
            Dashboard coming soon
          </p>
          <p className="mt-1 text-xs text-slate-400">
            We'll build this out next.
          </p>
        </div>
      </section>
    </main>
  );
}
