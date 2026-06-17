// Base URL of the Xano "Default" API group.
// Find it in Xano: API → Default group → the base URL shown at the top,
// e.g. https://xjno-rqiq-2v6x.<region>.xano.io/api:SQfzEqGW
// Set it in frontend/.env as VITE_XANO_BASE_URL.
const BASE_URL = import.meta.env.VITE_XANO_BASE_URL ?? "";

const TOKEN_KEY = "resolut.authToken";

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearToken(): void {
  localStorage.removeItem(TOKEN_KEY);
}

export class ApiError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

interface LoginResponse {
  authToken: string;
}

/**
 * POST auth/login — returns the Xano auth token on success.
 * Mirrors apis/default/1_auth_login_POST.xs.
 */
export async function login(email: string, password: string): Promise<string> {
  if (!BASE_URL) {
    throw new ApiError(
      "Login is not configured yet. Set VITE_XANO_BASE_URL in frontend/.env.",
      0
    );
  }

  let res: Response;
  try {
    res = await fetch(`${BASE_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });
  } catch {
    throw new ApiError("Network error — could not reach the server.", 0);
  }

  let body: unknown = null;
  try {
    body = await res.json();
  } catch {
    /* non-JSON response */
  }

  if (!res.ok) {
    const message =
      (body as { message?: string } | null)?.message ??
      (res.status === 401 || res.status === 403
        ? "Invalid email or password."
        : "Something went wrong. Please try again.");
    throw new ApiError(message, res.status);
  }

  const token = (body as LoginResponse | null)?.authToken;
  if (!token) {
    throw new ApiError("Unexpected response from server.", res.status);
  }
  return token;
}
