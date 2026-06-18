import { NavLink, useNavigate } from "react-router-dom";
import {
  LayoutDashboard,
  Building2,
  Users,
  FileText,
  Share2,
  BarChart2,
  GitBranch,
  Map,
  ClipboardList,
  CheckSquare,
  FileBarChart,
  UserPlus,
  BookOpen,
  Building,
  Settings,
  LogOut,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { useState } from "react";
import { useAuthStore } from "../store/auth";
import { LOGO } from "../lib/brand";

const NAV_SECTIONS = [
  {
    label: "Platform Navigation",
    items: [
      { label: "Dashboard", icon: LayoutDashboard, to: "/dashboard" },
      { label: "Organisation", icon: Building2, to: "/organisation" },
      { label: "Contacts", icon: Users, to: "/contacts" },
      { label: "Documents", icon: FileText, to: "/documents" },
      { label: "Share Documents", icon: Share2, to: "/share-documents" },
      { label: "Product Analysis", icon: BarChart2, to: "/product-analysis" },
      { label: "Processes", icon: GitBranch, to: "/processes" },
      { label: "Process Maps", icon: Map, to: "/process-maps" },
      { label: "Assessments", icon: ClipboardList, to: "/assessments" },
      { label: "Audits", icon: CheckSquare, to: "/audits" },
      { label: "Reports", icon: FileBarChart, to: "/reports" },
      { label: "Invites", icon: UserPlus, to: "/invites" },
    ],
  },
  {
    label: "Resources",
    items: [
      { label: "Regulations", icon: BookOpen, to: "/regulations" },
      { label: "Companies", icon: Building, to: "/companies" },
    ],
  },
  {
    label: "Settings",
    items: [{ label: "Settings", icon: Settings, to: "/settings" }],
  },
];

function userInitials(name: string | null | undefined, email: string): string {
  if (name) {
    return name
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() ?? "")
      .join("");
  }
  return email[0]?.toUpperCase() ?? "?";
}

export default function Sidebar() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);
  const logout = useAuthStore((s) => s.logout);
  const [collapsed, setCollapsed] = useState(false);

  function handleLogout() {
    logout();
    navigate("/login", { replace: true });
  }

  const w = collapsed ? "w-16" : "w-56";

  return (
    <aside
      className={`${w} shrink-0 flex flex-col bg-white border-r border-slate-200 transition-all duration-200 min-h-screen`}
    >
      {/* Logo */}
      <div className="h-14 flex items-center justify-between px-3 border-b border-slate-100">
        {!collapsed && (
          <img src={LOGO.proBlack} alt="Resolut.Pro" className="h-6 w-auto" />
        )}
        {collapsed && (
          <img src={LOGO.icon} alt="" className="h-7 w-7 mx-auto" />
        )}
        <button
          onClick={() => setCollapsed((c) => !c)}
          className="ml-auto p-1 rounded-md text-slate-400 hover:text-[#5e90c0] hover:bg-slate-100 transition"
          aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
        >
          {collapsed ? <ChevronRight size={14} /> : <ChevronLeft size={14} />}
        </button>
      </div>

      {/* User */}
      <div className={`flex items-center gap-2.5 px-3 py-3 border-b border-slate-100 ${collapsed ? "justify-center" : ""}`}>
        {user?.profile_img ? (
          <img
            src={user.profile_img}
            alt=""
            className="h-8 w-8 shrink-0 rounded-full object-cover"
          />
        ) : (
          <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-[#D5E8F0] text-[#1d2428] text-xs font-semibold">
            {userInitials(user?.name, user?.email ?? "?")}
          </span>
        )}
        {!collapsed && (
          <div className="min-w-0">
            <p className="truncate text-xs font-semibold text-[#1d2428]">
              {user?.name ?? user?.email}
            </p>
            <p className="truncate text-[10px] text-slate-400">{user?.email}</p>
          </div>
        )}
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-2">
        {NAV_SECTIONS.map((section) => (
          <div key={section.label} className="mb-1">
            {!collapsed && (
              <p className="px-3 pt-3 pb-1 text-[10px] font-semibold uppercase tracking-wider text-slate-400">
                {section.label}
              </p>
            )}
            {section.items.map(({ label, icon: Icon, to }) => (
              <NavLink
                key={to}
                to={to}
                className={({ isActive }) =>
                  [
                    "flex items-center gap-2.5 mx-1 px-2.5 py-2 rounded-lg text-xs font-medium transition",
                    isActive
                      ? "bg-[#5e90c0] text-white"
                      : "text-[#1d2428] hover:bg-[#D5E8F0] hover:text-[#5e90c0]",
                    collapsed ? "justify-center" : "",
                  ].join(" ")
                }
                title={collapsed ? label : undefined}
              >
                <Icon size={15} className="shrink-0" />
                {!collapsed && <span>{label}</span>}
              </NavLink>
            ))}
          </div>
        ))}
      </nav>

      {/* Logout */}
      <div className="border-t border-slate-100 p-2">
        <button
          onClick={handleLogout}
          className={`flex items-center gap-2.5 w-full px-2.5 py-2 rounded-lg text-xs font-medium text-slate-500 hover:bg-red-50 hover:text-red-600 transition ${collapsed ? "justify-center" : ""}`}
          title={collapsed ? "Log out" : undefined}
        >
          <LogOut size={15} className="shrink-0" />
          {!collapsed && <span>Log out</span>}
        </button>
      </div>
    </aside>
  );
}
