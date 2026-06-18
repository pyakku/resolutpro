import { useMemo, useState } from "react";
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

// Deterministic pastel background per company so the grid isn't monotone.
const AVATAR_COLORS = [
  "bg-blue-100 text-blue-800",
  "bg-violet-100 text-violet-800",
  "bg-emerald-100 text-emerald-800",
  "bg-amber-100 text-amber-800",
  "bg-rose-100 text-rose-800",
  "bg-cyan-100 text-cyan-800",
];

function avatarColor(name: string | null | undefined): string {
  const code = (name ?? "").charCodeAt(0) || 0;
  return AVATAR_COLORS[code % AVATAR_COLORS.length];
}

export default function SelectCompany() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);
  const selectCompany = useAuthStore((s) => s.selectCompany);
  const logout = useAuthStore((s) => s.logout);
  const [search, setSearch] = useState("");

  const { data, isLoading, isError, error, refetch, isFetching } = useQuery({
    queryKey: ["companies"],
    queryFn: getCompanies,
  });

  const options = useMemo<CompanyOption[]>(() => {
    const seen = new Set<number>();
    const deduped = (data ?? []).filter((opt) => {
      const id = opt.company?.id;
      if (id == null || seen.has(id)) return false;
      seen.add(id);
      return true;
    });
    const q = search.trim().toLowerCase();
    if (!q) return deduped;
    return deduped.filter((opt) =>
      (opt.companyName ?? opt.company?.Company_Name ?? "")
        .toLowerCase()
        .includes(q)
    );
  }, [data, search]);

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
      <header className="bg-[#5e90c0]">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 h-16 flex items-center justify-between">
          <img src={LOGO.proWhite} alt="Resolut.Pro" className="h-7 w-auto" />
          <button
            onClick={handleLogout}
            className="text-sm text-white/80 hover:text-white transition"
          >
            Log out
          </button>
        </div>
      </header>

      <section className="mx-auto max-w-5xl px-4 sm:px-6 py-10">
        <h1 className="text-2xl font-semibold text-[#1d2428]">
          {user?.name ? `Welcome back, ${user.name}` : "Select a company"}
        </h1>
        <p className="mt-1 text-sm text-slate-500">
          Choose the company you want to work in.
        </p>

        {/* Search */}
        {!isLoading && !isError && (data ?? []).length > 0 && (
          <div className="relative mt-6 max-w-sm">
            <svg
              className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400"
              viewBox="0 0 20 20" fill="currentColor"
            >
              <path fillRule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clipRule="evenodd" />
            </svg>
            <input
              type="search"
              placeholder="Search companies…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full rounded-xl border border-slate-200 bg-white pl-9 pr-4 py-2.5 text-sm text-[#1d2428] placeholder:text-slate-400 outline-none focus:border-[#5e90c0] focus:ring-4 focus:ring-[#5e90c0]/10"
            />
          </div>
        )}

        {isLoading && (
          <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="h-20 rounded-xl border border-slate-200 bg-white animate-pulse"
              />
            ))}
          </div>
        )}

        {isError && (
          <div className="mt-10 rounded-xl border border-red-200 bg-red-50 p-6 text-center">
            <p className="text-sm text-red-700">{errorMessage(error)}</p>
            <button
              onClick={() => refetch()}
              className="mt-3 rounded-lg bg-[#5e90c0] px-4 py-2 text-sm font-medium text-white hover:bg-[#4d7dae]"
            >
              Try again
            </button>
          </div>
        )}

        {!isLoading && !isError && options.length === 0 && (
          <div className="mt-10 rounded-xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-500">
            {search ? `No companies match "${search}".` : "No companies are linked to your account yet."}
          </div>
        )}

        {options.length > 0 && (
          <div className="mt-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
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
                  className="group text-left rounded-xl border border-slate-200 bg-white px-4 py-3.5 transition hover:border-[#5e90c0] hover:shadow-md focus:outline-none focus:ring-2 focus:ring-[#5e90c0]/40"
                >
                  <div className="flex items-center gap-3">
                    <span
                      className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg text-sm font-semibold ${avatarColor(name)}`}
                    >
                      {initials(name)}
                    </span>
                    <div className="min-w-0">
                      <p className="truncate font-medium text-[#1d2428] group-hover:text-[#5e90c0] transition">
                        {name}
                      </p>
                      {meta && (
                        <p className="truncate text-xs text-slate-500 mt-0.5">{meta}</p>
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
