import { Navigate, Outlet, useNavigate } from "react-router-dom";
import { LifeBuoy, ArrowLeftRight } from "lucide-react";
import Sidebar from "./Sidebar";
import { useAuthStore } from "../store/auth";

export default function AppLayout() {
  const navigate = useNavigate();
  const company = useAuthStore((s) => s.selectedCompany);
  const selectCompany = useAuthStore((s) => s.selectCompany);

  // Require a selected company for all app routes.
  if (!company) {
    return <Navigate to="/select-company" replace />;
  }

  function switchCompany() {
    selectCompany(null);
    navigate("/select-company", { replace: true });
  }

  const countryName =
    typeof company.country_code === "object" && company.country_code !== null
      ? (company.country_code as { name?: string }).name ?? null
      : null;

  return (
    <div className="flex h-screen overflow-hidden bg-slate-50">
      <Sidebar />

      <div className="flex flex-col flex-1 min-w-0">
        {/* Top bar */}
        <header className="h-14 bg-white border-b border-slate-200 flex items-center justify-between px-6 shrink-0">
          <div className="flex items-center gap-3">
            <div>
              <p className="text-sm font-semibold text-[#1d2428] leading-none">
                {company.Company_Name ?? "Company"}
              </p>
              {countryName && (
                <p className="text-[11px] text-slate-400 mt-0.5">{countryName}</p>
              )}
            </div>
          </div>

          <div className="flex items-center gap-3">
            <a
              href="mailto:support@resolut.pro"
              className="hidden sm:flex items-center gap-1.5 text-xs text-[#5e90c0] hover:underline"
            >
              <LifeBuoy size={13} />
              Raise a Support Ticket
            </a>

            <div className="h-4 w-px bg-slate-200" />

            <button
              onClick={switchCompany}
              className="flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-xs font-medium text-[#1d2428] hover:border-[#5e90c0] hover:text-[#5e90c0] transition"
            >
              <ArrowLeftRight size={12} />
              {company.Company_Name ?? "Switch"}
            </button>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
