import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import { useAuthStore } from "./store/auth";
import Login from "./pages/Login";
import SelectCompany from "./pages/SelectCompany";
import Dashboard from "./pages/Dashboard";

export default function App() {
  const token = useAuthStore((s) => s.token);

  return (
    <Routes>
      <Route
        path="/login"
        element={token ? <Navigate to="/select-company" replace /> : <Login />}
      />

      <Route element={<ProtectedRoute />}>
        <Route path="/select-company" element={<SelectCompany />} />
        <Route path="/dashboard" element={<Dashboard />} />
      </Route>

      <Route
        path="*"
        element={<Navigate to={token ? "/select-company" : "/login"} replace />}
      />
    </Routes>
  );
}
