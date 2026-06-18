import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useMutation } from "@tanstack/react-query";
import { Link, useNavigate } from "react-router-dom";
import { errorMessage, getMe, login } from "../lib/api";
import { useAuthStore } from "../store/auth";
import { LOGO } from "../lib/brand";

const schema = z.object({
  email: z.string().min(1, "Email is required").email("Enter a valid email."),
  password: z.string().min(1, "Password is required"),
});

type LoginForm = z.infer<typeof schema>;

function EyeIcon({ open }: { open: boolean }) {
  return open ? (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4">
      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94" />
      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19" />
      <line x1="1" y1="1" x2="23" y2="23" />
    </svg>
  ) : (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

export default function Login() {
  const navigate = useNavigate();
  const setToken = useAuthStore((s) => s.setToken);
  const setUser = useAuthStore((s) => s.setUser);
  const [showPassword, setShowPassword] = useState(false);
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginForm>({ resolver: zodResolver(schema) });

  const mutation = useMutation({
    mutationFn: async ({ email, password }: LoginForm) => {
      const token = await login(email.trim(), password);
      setToken(token);
      try {
        setUser(await getMe());
      } catch {
        /* non-fatal */
      }
      return token;
    },
    onSuccess: () => navigate("/select-company", { replace: true }),
    onError: (err) => setServerError(errorMessage(err)),
  });

  const onSubmit = (values: LoginForm) => {
    setServerError(null);
    mutation.mutate(values);
  };

  const submitting = mutation.isPending;

  return (
    <main className="min-h-screen flex">
      {/* ── Left brand panel (desktop only) ── */}
      <div className="hidden lg:flex lg:w-[52%] bg-[#1d2428] flex-col items-center justify-center p-16 relative overflow-hidden select-none">
        <div className="absolute -top-32 -left-32 w-[480px] h-[480px] rounded-full border border-white/5" />
        <div className="absolute -bottom-48 -right-48 w-[600px] h-[600px] rounded-full border border-white/5" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] rounded-full border border-white/[0.03]" />

        <div className="relative flex flex-col items-center text-center max-w-sm">
          <img
            src={LOGO.icon}
            alt=""
            aria-hidden="true"
            className="w-28 h-28 mb-10 drop-shadow-2xl"
          />
          <p className="text-white text-xl font-semibold tracking-wide mb-3">
            resolut<span className="text-[#5e90c0]">.</span>pro
          </p>
          <p className="text-slate-400 text-sm leading-relaxed">
            Enterprise compliance &amp; audit management for modern teams.
          </p>
        </div>

        <p className="absolute bottom-8 text-xs text-slate-600">
          © {new Date().getFullYear()} resolut.pro
        </p>
      </div>

      {/* ── Right form panel ── */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12 bg-white">
        <div className="w-full max-w-sm">
          {/* Mobile logo */}
          <div className="flex lg:hidden items-center gap-3 mb-10">
            <img src={LOGO.icon} alt="" className="h-9 w-9" />
            <img src={LOGO.proBlack} alt="Resolut.Pro" className="h-7 w-auto" />
          </div>

          <h1 className="text-[1.65rem] font-bold tracking-tight text-[#1d2428]">
            Welcome back
          </h1>
          <p className="mt-1.5 text-sm text-slate-500">
            Sign in to your account to continue.
          </p>

          {serverError && (
            <div
              role="alert"
              className="mt-5 flex items-start gap-2.5 rounded-xl bg-red-50 border border-red-100 px-4 py-3 text-sm text-red-700"
            >
              <svg className="mt-0.5 w-4 h-4 shrink-0" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
              </svg>
              {serverError}
            </div>
          )}

          <form onSubmit={handleSubmit(onSubmit)} noValidate className="mt-8 space-y-5">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1.5">
                Email address
              </label>
              <input
                type="email"
                autoComplete="email"
                placeholder="you@company.com"
                disabled={submitting}
                className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-[#1d2428] placeholder:text-slate-400 outline-none transition focus:border-[#5e90c0] focus:bg-white focus:ring-4 focus:ring-[#5e90c0]/10 disabled:opacity-50"
                {...register("email")}
              />
              {errors.email && (
                <p className="mt-1.5 text-xs text-red-600">{errors.email.message}</p>
              )}
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-sm font-medium text-slate-700">
                  Password
                </label>
                <Link
                  to="/forgot-password"
                  className="text-xs text-[#5e90c0] hover:underline"
                >
                  Forgot password?
                </Link>
              </div>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  placeholder="••••••••"
                  disabled={submitting}
                  className="w-full rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 pr-12 text-sm text-[#1d2428] placeholder:text-slate-400 outline-none transition focus:border-[#5e90c0] focus:bg-white focus:ring-4 focus:ring-[#5e90c0]/10 disabled:opacity-50"
                  {...register("password")}
                />
                <button
                  type="button"
                  tabIndex={-1}
                  onClick={() => setShowPassword((s) => !s)}
                  aria-label={showPassword ? "Hide password" : "Show password"}
                  className="absolute inset-y-0 right-0 flex items-center px-4 text-slate-400 hover:text-slate-600"
                >
                  <EyeIcon open={showPassword} />
                </button>
              </div>
              {errors.password && (
                <p className="mt-1.5 text-xs text-red-600">{errors.password.message}</p>
              )}
            </div>

            <button
              type="submit"
              disabled={submitting}
              className="mt-2 w-full rounded-xl bg-[#5e90c0] py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-[#4d7dae] active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
            >
              {submitting ? (
                <span className="flex items-center justify-center gap-2">
                  <svg className="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                  </svg>
                  Signing in…
                </span>
              ) : (
                "Sign in"
              )}
            </button>
          </form>

          <p className="mt-5 text-center text-xs text-slate-400 leading-relaxed">
            By continuing you agree to our{" "}
            <Link to="/terms" className="underline hover:text-slate-600">
              Terms of Service
            </Link>{" "}
            and{" "}
            <Link to="/privacy" className="underline hover:text-slate-600">
              Privacy Policy
            </Link>
            .
          </p>

          <p className="mt-5 text-center text-sm text-slate-500">
            Don't have an account?{" "}
            <Link to="/sign-up" className="font-medium text-[#5e90c0] hover:underline">
              Sign up
            </Link>
          </p>

          <p className="mt-8 text-center text-xs text-slate-400 lg:hidden">
            © {new Date().getFullYear()} resolut.pro
          </p>
        </div>
      </div>
    </main>
  );
}
