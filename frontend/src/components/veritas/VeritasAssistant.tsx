import { useState } from "react";
import { Sparkles } from "lucide-react";
import { useAuthStore } from "../../store/auth";
import VeritasOrb from "./VeritasOrb";
import VeritasChat from "./VeritasChat";

/**
 * Veritas assistant: a floating orb that toggles a chat panel. Mounted once in
 * the authed app shell so it's available on every page with company context.
 */
export default function VeritasAssistant() {
  const company = useAuthStore((s) => s.selectedCompany);
  const [open, setOpen] = useState(false);
  const [pending, setPending] = useState(false);

  if (!company?.id) return null;

  return (
    <div className="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-3">
      {open && (
        <div className="veritas-panel-in flex h-[520px] max-h-[calc(100vh-7rem)] w-[360px] max-w-[calc(100vw-3rem)] flex-col overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl">
          {/* Header */}
          <div
            className="flex items-center gap-2.5 px-4 py-3 text-white"
            style={{
              background:
                "linear-gradient(135deg, #5e90c0 0%, #1d2428 100%)",
            }}
          >
            <span className="flex h-7 w-7 items-center justify-center rounded-full bg-white/15">
              <Sparkles size={15} />
            </span>
            <div className="min-w-0">
              <p className="text-sm font-semibold leading-none">Veritas</p>
              <p className="mt-0.5 truncate text-[11px] text-white/70">
                AI assistant · {company.Company_Name ?? "your company"}
              </p>
            </div>
          </div>

          {/* Chat — keyed by company so switching companies resets the thread */}
          <div className="min-h-0 flex-1">
            <VeritasChat key={company.id} companyId={company.id} onPending={setPending} />
          </div>
        </div>
      )}

      <div className="self-end">
        <VeritasOrb open={open} active={pending} onClick={() => setOpen((o) => !o)} />
      </div>
    </div>
  );
}
