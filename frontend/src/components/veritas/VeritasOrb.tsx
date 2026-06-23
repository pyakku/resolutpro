import { Sparkles, X } from "lucide-react";

interface Props {
  open: boolean;
  /** True while the assistant is thinking — intensifies the lighting. */
  active: boolean;
  onClick: () => void;
}

/**
 * Floating Veritas orb. A layered, glowing sphere with an "activated" lighting
 * effect — a pulsing aura, a slow-rotating sheen, and a gentle bob. The glow
 * intensifies while the panel is open or the assistant is thinking.
 */
export default function VeritasOrb({ open, active, onClick }: Props) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={open ? "Close Veritas assistant" : "Open Veritas assistant"}
      className="group relative flex h-14 w-14 items-center justify-center"
    >
      {/* Outer pulsing aura */}
      <span
        aria-hidden
        className={`pointer-events-none absolute inset-0 rounded-full blur-md ${
          active || open ? "veritas-aura-fast" : "veritas-aura"
        }`}
        style={{
          background:
            "radial-gradient(circle, rgba(94,144,192,0.9) 0%, rgba(213,232,240,0.5) 45%, rgba(94,144,192,0) 70%)",
        }}
      />

      {/* Orb body */}
      <span
        aria-hidden
        className="relative flex h-12 w-12 items-center justify-center overflow-hidden rounded-full shadow-lg ring-1 ring-white/40 transition-transform duration-200 group-hover:scale-105 group-active:scale-95 veritas-bob"
        style={{
          background:
            "radial-gradient(circle at 32% 28%, #cfe6f2 0%, #5e90c0 42%, #1d2428 100%)",
        }}
      >
        {/* Rotating sheen */}
        <span
          aria-hidden
          className="absolute inset-[-30%] veritas-spin-slow opacity-70"
          style={{
            background:
              "conic-gradient(from 0deg, transparent 0deg, rgba(255,255,255,0.55) 60deg, transparent 140deg, transparent 360deg)",
          }}
        />
        {/* Glossy highlight */}
        <span
          aria-hidden
          className="absolute left-2 top-1.5 h-3 w-3 rounded-full bg-white/70 blur-[2px]"
        />
        {/* Icon */}
        <span className="relative text-white drop-shadow">
          {open ? <X size={20} /> : <Sparkles size={20} />}
        </span>
      </span>
    </button>
  );
}
