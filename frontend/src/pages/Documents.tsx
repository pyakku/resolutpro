import { useEffect, useMemo, useRef, useState } from "react";
import { useInfiniteQuery } from "@tanstack/react-query";
import { Search, FileText, AlertTriangle, Loader2 } from "lucide-react";
import { useAuthStore } from "../store/auth";
import { getDocuments } from "../lib/api";
import { errorMessage } from "../lib/api";
import type { DocumentStatus, MyDocument } from "../lib/types";
import DocumentModal from "../components/DocumentModal";

// ── Tabs ────────────────────────────────────────────────────────────────────────

const TABS: { key: DocumentStatus; label: string }[] = [
  { key: "all", label: "All documents" },
  { key: "validated", label: "Validated" },
  { key: "rejected", label: "Rejected" },
  { key: "expired", label: "Expired" },
  { key: "pending", label: "Pending validation" },
  { key: "archived", label: "Archived" },
];

// ── Status badge ────────────────────────────────────────────────────────────────

function effectiveStatus(d: MyDocument): { label: string; cls: string } {
  if (d.archived) return { label: "Archived", cls: "bg-slate-100 text-slate-500" };
  if (d.rejected) return { label: "Rejected", cls: "bg-red-100 text-red-600" };
  if (d.validated) return { label: "Validated", cls: "bg-emerald-100 text-emerald-600" };
  if (!d.noExpiry && d.expiryDate && d.expiryDate < Date.now())
    return { label: "Expired", cls: "bg-amber-100 text-amber-600" };
  return { label: "Pending", cls: "bg-slate-100 text-slate-500" };
}

function fmtDate(ts: number | null): string {
  if (!ts) return "—";
  return new Date(ts).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

// ── Row ─────────────────────────────────────────────────────────────────────────

function DocRow({
  doc,
  companyName,
  onOpen,
}: {
  doc: MyDocument;
  companyName: string | null;
  onOpen: () => void;
}) {
  const status = effectiveStatus(doc);
  const name = doc.nameUA ?? doc.documentInfo?.documentName ?? doc.file?.name ?? "Untitled document";
  const type = doc.documentInfo?.typeInfo?.type ?? "—";
  const isExpired = !doc.noExpiry && !!doc.expiryDate && doc.expiryDate < Date.now();
  // The holder is the document's contact; with no contact, the company holds it.
  const holderName = [doc.holderInfo?.name, doc.holderInfo?.l_name].filter(Boolean).join(" ").trim();
  const holder = holderName || companyName || "—";

  return (
    <button
      onClick={onOpen}
      className="grid w-full grid-cols-12 items-center gap-3 border-b border-slate-100 px-4 py-3 text-left transition hover:bg-slate-50"
    >
      <div className="col-span-3 flex min-w-0 items-center gap-3">
        <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-[#D5E8F0]">
          <FileText size={15} className="text-[#5e90c0]" />
        </span>
        <div className="min-w-0">
          <p className="truncate text-sm font-medium text-[#1d2428]">{name}</p>
          <p className="truncate text-[11px] text-slate-400">{doc.issuedBy || "—"}</p>
        </div>
      </div>
      <p className="col-span-2 truncate text-xs text-slate-500">{holder}</p>
      <p className="col-span-2 truncate text-xs text-slate-500">{type}</p>
      <p className="col-span-2 text-xs text-slate-500">{fmtDate(doc.issueDate)}</p>
      <p className={`col-span-2 text-xs ${isExpired ? "font-semibold text-red-600" : "text-slate-500"}`}>
        {doc.noExpiry ? "No expiry" : fmtDate(doc.expiryDate)}
      </p>
      <div className="col-span-1 flex justify-end">
        <span className={`rounded-full px-2 py-0.5 text-[10px] font-semibold ${status.cls}`}>
          {status.label}
        </span>
      </div>
    </button>
  );
}

function RowSkeleton() {
  return (
    <div className="grid grid-cols-12 items-center gap-3 border-b border-slate-100 px-4 py-3">
      <div className="col-span-3 flex items-center gap-3">
        <span className="h-8 w-8 shrink-0 animate-pulse rounded-lg bg-slate-100" />
        <span className="h-3 w-32 animate-pulse rounded bg-slate-100" />
      </div>
      <span className="col-span-2 h-3 w-20 animate-pulse rounded bg-slate-100" />
      <span className="col-span-2 h-3 w-16 animate-pulse rounded bg-slate-100" />
      <span className="col-span-2 h-3 w-20 animate-pulse rounded bg-slate-100" />
      <span className="col-span-2 h-3 w-20 animate-pulse rounded bg-slate-100" />
      <span className="col-span-1 h-4 w-14 animate-pulse justify-self-end rounded-full bg-slate-100" />
    </div>
  );
}

// ── Page ────────────────────────────────────────────────────────────────────────

export default function Documents() {
  const company = useAuthStore((s) => s.selectedCompany);
  const [status, setStatus] = useState<DocumentStatus>("all");
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [openDoc, setOpenDoc] = useState<MyDocument | null>(null);

  // Debounce the search box → server-side `search` param.
  useEffect(() => {
    const t = setTimeout(() => setSearch(searchInput), 300);
    return () => clearTimeout(t);
  }, [searchInput]);

  const {
    data,
    error,
    isLoading,
    isError,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ["documents", company?.id, status, search],
    enabled: !!company?.id,
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      getDocuments({ companyId: company!.id, status, search, page: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextPage ?? undefined,
  });

  const docs = useMemo(() => data?.pages.flatMap((p) => p.items) ?? [], [data]);

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
      <div>
        <h1 className="text-xl font-bold text-[#1d2428]">Documents</h1>
        <p className="mt-0.5 text-xs text-slate-400">
          Manage and review {company?.Company_Name ?? "your company"}'s documents.
        </p>
      </div>

      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
        {/* Tabs + search */}
        <div className="flex flex-col gap-3 px-4 pt-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="flex gap-0 overflow-x-auto border-b border-slate-200 sm:border-0">
            {TABS.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setStatus(tab.key)}
                className={[
                  "shrink-0 whitespace-nowrap border-b-2 px-3 py-2 text-xs font-medium transition",
                  status === tab.key
                    ? "border-[#5e90c0] text-[#5e90c0]"
                    : "border-transparent text-slate-500 hover:text-[#1d2428]",
                ].join(" ")}
              >
                {tab.label}
              </button>
            ))}
          </div>
          <div className="relative shrink-0 sm:w-64">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              placeholder="Search documents…"
              className="w-full rounded-lg border border-slate-200 py-2 pl-9 pr-3 text-xs text-[#1d2428] placeholder:text-slate-400 outline-none focus:border-[#5e90c0] focus:ring-2 focus:ring-[#5e90c0]/10"
            />
          </div>
        </div>

        {/* Column headers */}
        <div className="mt-2 grid grid-cols-12 gap-3 border-b border-slate-200 bg-slate-50 px-4 py-2 text-[10px] font-semibold uppercase tracking-wide text-slate-400">
          <span className="col-span-3">Name</span>
          <span className="col-span-2">Holder</span>
          <span className="col-span-2">Type</span>
          <span className="col-span-2">Issued</span>
          <span className="col-span-2">Expires</span>
          <span className="col-span-1 text-right">Status</span>
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
            <p className="text-xs">{errorMessage(error, "Could not load documents.")}</p>
          </div>
        ) : docs.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-slate-400">
            <FileText size={24} className="mb-2 opacity-30" />
            <p className="text-xs">No documents to show.</p>
          </div>
        ) : (
          <div>
            {docs.map((doc) => (
              <DocRow
                key={doc.id}
                doc={doc}
                companyName={company?.Company_Name ?? null}
                onOpen={() => setOpenDoc(doc)}
              />
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
                {docs.length} document{docs.length === 1 ? "" : "s"} loaded
              </p>
            )}
          </div>
        )}
      </div>

      {openDoc && <DocumentModal doc={openDoc} onClose={() => setOpenDoc(null)} />}
    </div>
  );
}
