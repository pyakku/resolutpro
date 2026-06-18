import { useLocation } from "react-router-dom";
import { Construction } from "lucide-react";

function pageTitle(pathname: string): string {
  return pathname
    .replace(/^\//, "")
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

export default function ComingSoon() {
  const { pathname } = useLocation();
  return (
    <div>
      <h1 className="text-xl font-bold text-[#1d2428]">{pageTitle(pathname)}</h1>
      <div className="mt-10 flex flex-col items-center justify-center rounded-xl border border-dashed border-slate-300 bg-white py-20 text-slate-400">
        <Construction size={32} className="mb-3 text-[#5e90c0] opacity-60" />
        <p className="text-sm font-medium">Coming soon</p>
        <p className="mt-1 text-xs">This page is under construction.</p>
      </div>
    </div>
  );
}
