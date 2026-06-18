import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import AppLayout from "./components/AppLayout";
import { useAuthStore } from "./store/auth";
import Login from "./pages/Login";
import SelectCompany from "./pages/SelectCompany";
import Dashboard from "./pages/Dashboard";

export default function App() {
  const token = useAuthStore((s) => s.token);

  return (
    <Routes>
      {/* Public */}
      <Route
        path="/login"
        element={token ? <Navigate to="/select-company" replace /> : <Login />}
      />
      <Route path="/forgot-password" element={<Login />} />
      <Route path="/sign-up" element={<Login />} />
      <Route path="/terms" element={<Login />} />
      <Route path="/privacy" element={<Login />} />

      {/* Requires auth token */}
      <Route element={<ProtectedRoute />}>
        <Route path="/select-company" element={<SelectCompany />} />

        {/* Requires token + selected company — AppLayout enforces the company guard */}
        <Route element={<AppLayout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          {/* Future routes: organisation, contacts, documents, etc. */}
        </Route>
      </Route>

      <Route
        path="*"
        element={<Navigate to={token ? "/select-company" : "/login"} replace />}
      />
    </Routes>
  );
}
