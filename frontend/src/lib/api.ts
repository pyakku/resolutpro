import axios, { AxiosError } from "axios";
import { useAuthStore } from "../store/auth";
import type { CompanyOption, DashboardStats, User } from "./types";

// Base URL of the Xano `resolut_apis` API group. Set in frontend/.env.
const BASE_URL = import.meta.env.VITE_XANO_BASE_URL ?? "";

export const api = axios.create({
  baseURL: BASE_URL,
  headers: { "Content-Type": "application/json" },
});

// Attach the auth token (read live from the store) to every request.
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// On an expired/invalid token, drop the session so guards send the user back
// to login.
api.interceptors.response.use(
  (res) => res,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
    }
    return Promise.reject(error);
  }
);

/** Turn an Axios/Xano error into a human-readable message. */
export function errorMessage(err: unknown, fallback = "Something went wrong."): string {
  if (axios.isAxiosError(err)) {
    if (!err.response) return "Network error — could not reach the server.";
    const data = err.response.data as { message?: string } | undefined;
    if (data?.message) return data.message;
    if (err.response.status === 401 || err.response.status === 403) {
      return "Invalid email or password.";
    }
  }
  return fallback;
}

interface LoginResponse {
  authToken: string;
}

/** POST auth/login — returns the Xano auth token. */
export async function login(email: string, password: string): Promise<string> {
  if (!BASE_URL) {
    throw new Error("VITE_XANO_BASE_URL is not set. See frontend/.env.example.");
  }
  const { data } = await api.post<LoginResponse>("/auth/login", { email, password });
  return data.authToken;
}

/** GET auth/me — the currently authenticated user. */
export async function getMe(): Promise<User> {
  const { data } = await api.get<User>("/auth/me");
  return data;
}

/** GET company_of_current_user_v2_ff — companies the user can access. */
export async function getCompanies(): Promise<CompanyOption[]> {
  const { data } = await api.get<CompanyOption[]>("/user/list_companies");
  return Array.isArray(data) ? data : [];
}

/** GET dashboard/stats/numbers — top-row KPI counts for a company. */
export async function getDashboardStats(companyId: number): Promise<DashboardStats> {
  const { data } = await api.get<DashboardStats>("/dashboard/stats/numbers", {
    params: { company_id: companyId },
  });
  return data;
}
