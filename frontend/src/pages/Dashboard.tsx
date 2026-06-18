import { useState } from "react";
import {
  GitBranch,
  Package,
  FileText,
  CheckSquare,
  Users,
  Contact,
  UserPlus,
  AlertTriangle,
} from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { useAuthStore } from "../store/auth";
import { getDashboardStats } from "../lib/api";

// ── Stat card ─────────────────────────────────────────────────────────────────

interface StatCardProps {
  label: string;
  value: number | string;
  icon: React.ReactNode;
  iconBg: string;
  sub?: { label: string; value: number | string }[];
}

function StatCard({ label, value, icon, iconBg, sub }: StatCardProps) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 flex items-start gap-3">
      <span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg ${iconBg}`}>
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-[11px] text-slate-500 font-medium">{label}</p>
        <p className="text-2xl font-bold text-[#1d2428] leading-tight">{value}</p>
        {sub && (
          <div className="flex gap-3 mt-1">
            {sub.map((s) => (
              <span key={s.label} className="text-[10px] text-slate-400">
                <span className="text-[#5e90c0] font-semibold">{s.value}</span>{" "}
                {s.label}
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ── Progress bar ───────────────────────────────────────────────────────────────

function AuditBar({ label, done, total }: { label: string; done: number; total: number }) {
  const pct = total > 0 ? (done / total) * 100 : 0;
  const color = pct === 0 ? "bg-red-400" : pct < 50 ? "bg-amber-400" : "bg-emerald-500";
  return (
    <div className="flex items-center gap-3">
      <span className="w-36 text-xs text-[#1d2428] truncate shrink-0">{label}</span>
      <div className="flex-1 h-5 rounded-full bg-slate-100 overflow-hidden">
        <div
          className={`h-full rounded-full ${color} transition-all`}
          style={{ width: `${Math.max(pct, pct === 0 ? 100 : 0)}%` }}
        />
      </div>
      <span className="text-xs text-white font-semibold bg-slate-400 rounded-full px-2 py-0.5 shrink-0 min-w-[3rem] text-center"
        style={{ background: pct === 0 ? "#f87171" : pct < 50 ? "#fbbf24" : "#34d399" }}
      >
        {done}/{total}
      </span>
    </div>
  );
}

// ── Outstanding tasks tabs ─────────────────────────────────────────────────────

const TASK_TABS = [
  "Review Documents",
  "Review Relationships",
  "Pending Acknowledgement",
  "KPIs",
];

function OutstandingTasks() {
  const [active, setActive] = useState(0);
  return (
    <div className="bg-white rounded-xl border border-slate-200 overflow-hidden h-full">
      <div className="px-4 pt-4 pb-0">
        <h2 className="text-sm font-semibold text-[#1d2428]">Outstanding Tasks</h2>
        <p className="text-xs text-slate-400 mt-0.5">
          Below are the outstanding tasks on your account.
        </p>
        <div className="flex gap-0 mt-4 border-b border-slate-200 overflow-x-auto">
          {TASK_TABS.map((tab, i) => (
            <button
              key={tab}
              onClick={() => setActive(i)}
              className={[
                "shrink-0 px-3 py-2 text-xs font-medium border-b-2 transition whitespace-nowrap",
                active === i
                  ? "border-[#5e90c0] text-[#5e90c0]"
                  : "border-transparent text-slate-500 hover:text-[#1d2428]",
              ].join(" ")}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>
      <div className="flex flex-col items-center justify-center py-12 text-slate-400">
        <AlertTriangle size={24} className="mb-2 opacity-30" />
        <p className="text-xs">No items to show.</p>
      </div>
    </div>
  );
}

// ── Invite card ────────────────────────────────────────────────────────────────

function InviteCard() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h2 className="text-sm font-semibold text-[#1d2428]">Invite to Resolut.Pro</h2>
          <p className="text-xs text-slate-400 mt-0.5">Invite a new user to the platform.</p>
        </div>
        <button className="flex items-center gap-1.5 text-xs text-[#5e90c0] border border-[#5e90c0] rounded-lg px-3 py-1.5 hover:bg-[#D5E8F0] transition">
          View
        </button>
      </div>
      <div className="flex gap-2">
        <input
          type="text"
          placeholder="Enter Name…"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="flex-1 rounded-lg border border-slate-200 px-3 py-2 text-xs text-[#1d2428] placeholder:text-slate-400 outline-none focus:border-[#5e90c0] focus:ring-2 focus:ring-[#5e90c0]/10"
        />
        <input
          type="email"
          placeholder="Enter Email…"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="flex-1 rounded-lg border border-slate-200 px-3 py-2 text-xs text-[#1d2428] placeholder:text-slate-400 outline-none focus:border-[#5e90c0] focus:ring-2 focus:ring-[#5e90c0]/10"
        />
        <button className="flex items-center gap-1.5 rounded-lg bg-[#5e90c0] px-4 py-2 text-xs font-semibold text-white hover:bg-[#4d7dae] transition">
          <UserPlus size={13} />
          Send Invite
        </button>
      </div>
    </div>
  );
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

export default function Dashboard() {
  const company = useAuthStore((s) => s.selectedCompany);

  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ["dashboard-stats", company?.id],
    queryFn: () => getDashboardStats(company!.id),
    enabled: !!company?.id,
  });

  const n = (v: number | undefined) =>
    statsLoading ? "…" : v !== undefined ? v : "—";

  return (
    <div className="space-y-6">
      {/* Page heading */}
      <div>
        <h1 className="text-xl font-bold text-[#1d2428]">
          {company?.Company_Name ?? "Dashboard"}
        </h1>
        <p className="text-xs text-slate-400 mt-0.5">
          Here's an overview of your compliance status.
        </p>
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-6 gap-3">
        <StatCard
          label="Processes"
          value={n(stats?.processes)}
          iconBg="bg-[#D5E8F0]"
          icon={<GitBranch size={18} className="text-[#5e90c0]" />}
        />
        <StatCard
          label="Products"
          value={n(stats?.products)}
          iconBg="bg-violet-100"
          icon={<Package size={18} className="text-violet-500" />}
        />
        <StatCard
          label="Documents"
          value={n(stats?.documents)}
          iconBg="bg-amber-100"
          icon={<FileText size={18} className="text-amber-500" />}
          sub={[
            { label: "Active", value: n(stats?.validatedDocuments) },
            { label: "Rejected", value: n(stats?.rejectedDocuments) },
            { label: "Archived", value: n(stats?.archivedDocuments) },
          ]}
        />
        <StatCard
          label="Audits"
          value={n(stats?.audits)}
          iconBg="bg-emerald-100"
          icon={<CheckSquare size={18} className="text-emerald-500" />}
        />
        <StatCard
          label="Users"
          value={n(stats?.users)}
          iconBg="bg-rose-100"
          icon={<Users size={18} className="text-rose-500" />}
        />
        <StatCard
          label="Contacts"
          value={n(stats?.contacts)}
          iconBg="bg-indigo-100"
          icon={<Contact size={18} className="text-indigo-500" />}
        />
      </div>

      {/* Main grid */}
      <div className="grid grid-cols-1 xl:grid-cols-5 gap-6">
        {/* Left column */}
        <div className="xl:col-span-3 space-y-4">
          {/* Suppliers */}
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h2 className="text-sm font-semibold text-[#1d2428]">Suppliers</h2>
                <p className="text-xs text-slate-400 mt-0.5">
                  An overview of your suppliers.
                </p>
              </div>
              <button className="flex items-center gap-1.5 rounded-lg bg-[#5e90c0] px-3 py-1.5 text-xs font-semibold text-white hover:bg-[#4d7dae] transition">
                + Add
              </button>
            </div>
            <div className="flex gap-8">
              <div>
                <p className="text-3xl font-bold text-[#1d2428]">—</p>
                <p className="text-xs text-slate-400 mt-1">Suppliers</p>
              </div>
              <div>
                <p className="text-3xl font-bold text-[#5e90c0]">—</p>
                <p className="text-xs text-slate-400 mt-1">Non Compliant</p>
              </div>
            </div>
          </div>

          {/* Regulatory Compliance Readiness */}
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <div className="flex items-start gap-1.5 mb-4">
              <h2 className="text-sm font-semibold text-[#1d2428]">
                Regulatory Compliance Readiness
              </h2>
            </div>
            <p className="text-xs text-slate-400 mb-4">
              An overview of your readiness by regulator.
            </p>
            <div className="flex flex-col items-center py-6 text-slate-400">
              <AlertTriangle size={24} className="mb-2 opacity-30" />
              <p className="text-xs">No Assessment Details to Show.</p>
            </div>
          </div>

          {/* Upcoming Audits */}
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <h2 className="text-sm font-semibold text-[#1d2428] mb-1">
              Upcoming Audits
            </h2>
            <p className="text-xs text-slate-400 mb-4">
              An overview of your readiness for upcoming audits.
            </p>
            <div className="space-y-3">
              <AuditBar label="Example Audit 1" done={0} total={1} />
              <AuditBar label="Example Audit 2" done={0} total={6} />
              <AuditBar label="Example Audit 3" done={2} total={4} />
            </div>
            <p className="mt-3 text-[10px] text-slate-400">
              * Placeholder data — wire to API when audits are built.
            </p>
          </div>

          {/* Invite */}
          <InviteCard />
        </div>

        {/* Right column */}
        <div className="xl:col-span-2 min-h-[400px]">
          <OutstandingTasks />
        </div>
      </div>
    </div>
  );
}
