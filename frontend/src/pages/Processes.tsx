import { useEffect, useMemo, useRef, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { useInfiniteQuery } from "@tanstack/react-query";
import {
  Search,
  GitBranch,
  AlertTriangle,
  Loader2,
  CheckCircle2,
  MinusCircle,
} from "lucide-react";
import { useAuthStore } from "../store/auth";
import { getProcesses, errorMessage } from "../lib/api";
import type { Relationship } from "../lib/types";

// ── Helpers ───────────────────────────────────────────────────────────────────

function fmtDate(ts: number | null): string {
  if (!ts) return "—";
  return new Date(ts).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

function companyName(c: Relationship["dataOwner"]): string {
  return c?.Company_Name?.trim() || "—";
}

/** A contiguous run of relationship rows sharing one PTN number — a PTN chain. */
interface PtnGroup {
  ptn: string;
  rows: Relationship[];
}

/**
 * Group the flat, PTN-sorted rows into PTN chains. Rows of the same PTN are
 * contiguous (the server sorts by PTN_no), so we accumulate until the PTN
 * changes. This also merges a chain that straddles a lazy-loaded page boundary.
 */
function groupByPtn(rows: Relationship[]): PtnGroup[] {
  const groups: PtnGroup[] = [];
  for (const row of rows) {
    const ptn = row.PTN_no ?? "—";
    const last = groups[groups.length - 1];
    if (last && last.ptn === ptn) last.rows.push(row);
    else groups.push({ ptn, rows: [row] });
  }
  return groups;
}

// ── Row ─────────────────────────────────────────────────────────────────────────

function ProcessRow({ row }: { row: Relationship }) {
  const hasSla = !!row.sla?.url;
  return (
    <div className="grid grid-cols-12 items-center gap-3 border-b border-slate-100 px-4 py-3 text-xs transition hover:bg-slate-50">
      <span className="col-span-2 truncate font-medium text-[#1d2428]">
        {row.PTN_no || "—"}
      </span>
      <span className="col-span-1 text-slate-500">{fmtDate(row.created_at)}</span>
      <span className="col-span-2 truncate text-slate-600" title={row.desc ?? ""}>
        {row.desc?.trim() || "—"}
      </span>
      <span className="col-span-1 truncate text-slate-500">{companyName(row.dataOwner)}</span>
      <span className="col-span-1 truncate text-slate-500">{companyName(row.assignedBy)}</span>
      <span className="col-span-1 truncate text-slate-500">
        {row.functionInfo?.function?.trim() || "—"}
      </span>
      <span className="col-span-1 truncate text-slate-500">
        {row.countryInfo?.Name?.trim() || "—"}
      </span>
      <span className="col-span-2 truncate text-slate-500">{companyName(row.processor)}</span>
      <div className="col-span-1 flex justify-center">
        {hasSla ? (
          <a
            href={row.sla!.url}
            target="_blank"
            rel="noreferrer"
            title="View SLA"
            className="text-emerald-500 transition hover:text-emerald-600"
          >
            <CheckCircle2 size={18} />
          </a>
        ) : (
          <span title="No SLA on file" className="text-red-400">
            <MinusCircle size={18} />
          </span>
        )}
      </div>
    </div>
  );
}

// ── PTN group band ────────────────────────────────────────────────────────────

function PtnBand({ group }: { group: PtnGroup }) {
  return (
    <div className="flex items-center justify-between bg-[#5e90c0] px-4 py-2 text-sm font-semibold text-white">
      <span className="truncate">{group.ptn}</span>
      <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-white px-1.5 text-[11px] font-bold text-[#5e90c0]">
        {group.rows.length}
      </span>
    </div>
  );
}

function RowSkeleton() {
  return (
    <div className="grid grid-cols-12 items-center gap-3 border-b border-slate-100 px-4 py-3">
      <span className="col-span-2 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-2 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-2 h-3 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-4 w-4 animate-pulse justify-self-center rounded-full bg-slate-100" />
    </div>
  );
}

// ── Page ──────────────────────────────────────────────────────────────────────

export default function Processes() {
  const company = useAuthStore((s) => s.selectedCompany);
  // Seed the search from the URL (?search=PTN) so Veritas can deep-link a PTN.
  const [searchParams] = useSearchParams();
  const [searchInput, setSearchInput] = useState(() => searchParams.get("search") ?? "");
  const [search, setSearch] = useState(() => searchParams.get("search") ?? "");

  // Debounce the search box → server-side `search` param (matches PTN number).
  useEffect(() => {
    const t = setTimeout(() => setSearch(searchInput), 300);
    return () => clearTimeout(t);
  }, [searchInput]);

  // Follow URL changes (e.g. clicking another Veritas PTN card while already here).
  useEffect(() => {
    const q = searchParams.get("search") ?? "";
    setSearchInput(q);
    setSearch(q);
  }, [searchParams]);

  const {
    data,
    error,
    isLoading,
    isError,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ["processes", company?.id, search],
    enabled: !!company?.id,
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      getProcesses({ companyId: company!.id, search, page: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextPage ?? undefined,
  });

  const rows = useMemo(() => data?.pages.flatMap((p) => p.items) ?? [], [data]);
  const groups = useMemo(() => groupByPtn(rows), [rows]);

  // Infinite-scroll sentinel.
  const sentinel = useRef<HTMLDivElement | null>(null);
  useEffect(() => {
    const el = sentinel.current;
    if (!el || !hasNextPage) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isFetchingNextPage) fetchNextPage();
      },
      { rootMargin: "200px" }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  return (
    <div className="space-y-6">
      {/* Heading */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="flex items-center gap-2 text-xl font-bold text-[#1d2428]">
            <GitBranch size={20} className="text-[#5e90c0]" />
            Processes
          </h1>
          <p className="mt-0.5 text-xs text-slate-400">
            {company?.Company_Name ?? "Your company"}'s processes, grouped by PTN chain.
          </p>
        </div>
        <div className="relative shrink-0 sm:w-64">
          <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            placeholder="Search by PTN number…"
            className="w-full rounded-lg border border-slate-200 py-2 pl-9 pr-3 text-xs text-[#1d2428] placeholder:text-slate-400 outline-none focus:border-[#5e90c0] focus:ring-2 focus:ring-[#5e90c0]/10"
          />
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
        {/* Column headers */}
        <div className="grid grid-cols-12 gap-3 border-b border-slate-200 bg-slate-50 px-4 py-2 text-[10px] font-semibold uppercase tracking-wide text-slate-400">
          <span className="col-span-2">PTN</span>
          <span className="col-span-1">Created On</span>
          <span className="col-span-2">Description</span>
          <span className="col-span-1">Data Originator</span>
          <span className="col-span-1">Assigned By</span>
          <span className="col-span-1">Function</span>
          <span className="col-span-1">Country</span>
          <span className="col-span-2">Processor</span>
          <span className="col-span-1 text-center">SLA</span>
        </div>

        {/* Body */}
        {isLoading ? (
          <div>
            {Array.from({ length: 6 }).map((_, i) => (
              <RowSkeleton key={i} />
            ))}
          </div>
        ) : isError ? (
          <div className="flex flex-col items-center justify-center py-16 text-slate-400">
            <AlertTriangle size={24} className="mb-2 text-red-400 opacity-60" />
            <p className="text-xs">{errorMessage(error, "Could not load processes.")}</p>
          </div>
        ) : groups.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-slate-400">
            <GitBranch size={24} className="mb-2 opacity-30" />
            <p className="text-xs">No processes to show.</p>
          </div>
        ) : (
          <div>
            {groups.map((group) => (
              <div key={group.ptn}>
                <PtnBand group={group} />
                {group.rows.map((row) => (
                  <ProcessRow key={row.id} row={row} />
                ))}
              </div>
            ))}
            {/* Lazy-load sentinel + spinner */}
            <div ref={sentinel} />
            {isFetchingNextPage && (
              <div className="flex items-center justify-center py-4 text-slate-400">
                <Loader2 size={16} className="animate-spin" />
              </div>
            )}
            {!hasNextPage && (
              <p className="py-3 text-center text-[10px] text-slate-300">
                {groups.length} PTN{groups.length === 1 ? "" : "s"} · {rows.length} process
                {rows.length === 1 ? "" : "es"} loaded
              </p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
