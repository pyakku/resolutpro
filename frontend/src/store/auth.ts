import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { Company, User } from "../lib/types";

interface AuthState {
  token: string | null;
  user: User | null;
  selectedCompany: Company | null;

  setToken: (token: string | null) => void;
  setUser: (user: User | null) => void;
  selectCompany: (company: Company | null) => void;
  logout: () => void;
}

/**
 * Auth + active-company context, persisted to localStorage so a refresh keeps
 * the user signed in and on their chosen company.
 */
export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      selectedCompany: null,

      setToken: (token) => set({ token }),
      setUser: (user) => set({ user }),
      selectCompany: (selectedCompany) => set({ selectedCompany }),
      logout: () => set({ token: null, user: null, selectedCompany: null }),
    }),
    { name: "resolut.auth" }
  )
);
