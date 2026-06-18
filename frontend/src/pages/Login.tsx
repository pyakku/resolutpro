import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useMutation } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { errorMessage, getMe, login } from "../lib/api";
import { useAuthStore } from "../store/auth";
import { LOGO } from "../lib/brand";

const schema = z.object({
  email: z.string().min(1, "Email is required").email("Enter a valid email."),
  password: z.string().min(1, "Password is required"),
});

type LoginForm = z.infer<typeof schema>;

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
      // Best-effort: hydrate the user so the picker/dashboard can greet them.
      try {
        setUser(await getMe());
      } catch {
        /* non-fatal — guards only need the token */
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
    <main className="min-h-screen flex items-center justify-center bg-brand-dark px-4">
      <div className="w-full max-w-md">
        <form
          onSubmit={handleSubmit(onSubmit)}
          noValidate
          className="bg-white rounded-2xl shadow-xl p-8 sm:p-10"
        >
          <img
            src={LOGO.proBlack}
            alt="Resolut.Pro"
            className="h-9 w-auto mb-8"
          />

          <h1 className="text-2xl font-semibold text-brand-dark">Login</h1>
          <p className="mt-1 text-sm text-slate-500">
            Welcome back. Please enter your details.
          </p>

          {serverError && (
            <div
              role="alert"
              className="mt-5 rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700"
            >
              {serverError}
            </div>
          )}

          <div className="mt-6 space-y-5">
            <label className="block">
              <span className="block text-sm font-medium text-slate-700 mb-1.5">
                Email
              </span>
              <input
                type="email"
                autoComplete="email"
                placeholder="you@company.com"
                disabled={submitting}
                className="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand/30 disabled:opacity-60"
                {...register("email")}
              />
              {errors.email && (
                <span className="mt-1 block text-xs text-red-600">
                  {errors.email.message}
                </span>
              )}
            </label>

            <label className="block">
              <span className="block text-sm font-medium text-slate-700 mb-1.5">
                Password
              </span>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  placeholder="••••••••"
                  disabled={submitting}
                  className="w-full rounded-lg border border-slate-300 px-3 py-2.5 pr-16 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand/30 disabled:opacity-60"
                  {...register("password")}
                />
                <button
                  type="button"
                  tabIndex={-1}
                  onClick={() => setShowPassword((s) => !s)}
                  className="absolute inset-y-0 right-0 px-3 text-xs font-medium text-brand hover:text-brand-dark"
                >
                  {showPassword ? "Hide" : "Show"}
                </button>
              </div>
              {errors.password && (
                <span className="mt-1 block text-xs text-red-600">
                  {errors.password.message}
                </span>
              )}
            </label>
          </div>

          <button
            type="submit"
            disabled={submitting}
            className="mt-7 w-full rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:bg-brand-dark disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "Logging in…" : "Login"}
          </button>
        </form>

        <p className="mt-6 text-center text-xs text-slate-400">
          © {new Date().getFullYear()} resolut.pro
        </p>
      </div>
    </main>
  );
}
