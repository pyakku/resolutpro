import { useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { errorMessage, getCompanies } from "../lib/api";
import { useAuthStore } from "../store/auth";
import type { Company, CompanyOption } from "../lib/types";
import { LOGO } from "../lib/brand";

function initials(name: string | null | undefined): string {
  if (!name) return "?";
  return name
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase() ?? "")
    .join("");
}

export default function SelectCompany() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);
  const selectCompany = useAuthStore((s) => s.selectCompany);
  const logout = useAuthStore((s) => s.logout);

  const { data, isLoading, isError, error, refetch, isFetching } = useQuery({
    queryKey: ["companies"],
    queryFn: getCompanies,
  });

  // Guard against duplicate companies appearing across owned + addon access.
  const options = useMemo<CompanyOption[]>(() => {
    const seen = new Set<number>();
    return (data ?? []).filter((opt) => {
      const id = opt.company?.id;
      if (id == null || seen.has(id)) return false;
      seen.add(id);
      return true;
    });
  }, [data]);

  function choose(company: Company) {
    selectCompany(company);
    navigate("/dashboard", { replace: true });
  }

  function handleLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  return (
    <main className="min-h-screen bg-slate-50">
      <header className="bg-brand-dark">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 h-16 flex items-center justify-between">
          <img src={LOGO.proWhite} alt="Resolut.Pro" className="h-7 w-auto" />
          <button
            onClick={handleLogout}
            className="text-sm text-slate-300 hover:text-white"
          >
            Log out
          </button>
        </div>
      </header>

      <section className="mx-auto max-w-5xl px-4 sm:px-6 py-10">
        <h1 className="text-2xl font-semibold text-brand-dark">
          {user?.name ? `Welcome back, ${user.name}` : "Select a company"}
        </h1>
        <p className="mt-1 text-sm text-slate-500">
          Choose the company you want to work in.
        </p>

        {isLoading && (
          <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="h-28 rounded-xl border border-slate-200 bg-white animate-pulse"
              />
            ))}
          </div>
        )}

        {isError && (
          <div className="mt-10 rounded-xl border border-red-200 bg-red-50 p-6 text-center">
            <p className="text-sm text-red-700">{errorMessage(error)}</p>
            <button
              onClick={() => refetch()}
              className="mt-3 rounded-lg bg-brand px-4 py-2 text-sm font-medium text-white hover:bg-brand-dark"
            >
              Try again
            </button>
          </div>
        )}

        {!isLoading && !isError && options.length === 0 && (
          <div className="mt-10 rounded-xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-500">
            No companies are linked to your account yet.
          </div>
        )}

        {options.length > 0 && (
          <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {options.map((opt) => {
              const company = opt.company;
              const name = opt.companyName ?? company.Company_Name ?? "Untitled";
              const meta = [company.industry, company.city, company.country]
                .filter(Boolean)
                .join(" · ");
              return (
                <button
                  key={company.id}
                  onClick={() => choose(company)}
                  className="group text-left rounded-xl border border-slate-200 bg-white p-5 transition hover:border-brand hover:shadow-md focus:outline-none focus:ring-2 focus:ring-brand/40"
                >
                  <div className="flex items-center gap-3">
                    {company.profile_link ? (
                      <img
                        src={company.profile_link}
                        alt=""
                        className="h-11 w-11 rounded-lg object-cover bg-slate-100"
                      />
                    ) : (
                      <span className="flex h-11 w-11 items-center justify-center rounded-lg bg-brand-light text-sm font-semibold text-brand-dark">
                        {initials(name)}
                      </span>
                    )}
                    <div className="min-w-0">
                      <p className="truncate font-medium text-brand-dark group-hover:text-brand">
                        {name}
                      </p>
                      {meta && (
                        <p className="truncate text-xs text-slate-500">{meta}</p>
                      )}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        )}

        {isFetching && !isLoading && (
          <p className="mt-4 text-xs text-slate-400">Refreshing…</p>
        )}
      </section>
    </main>
  );
}
