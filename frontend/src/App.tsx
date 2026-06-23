import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import AppLayout from "./components/AppLayout";
import { useAuthStore } from "./store/auth";
import Login from "./pages/Login";
import SelectCompany from "./pages/SelectCompany";
import Dashboard from "./pages/Dashboard";
import Documents from "./pages/Documents";
import Processes from "./pages/Processes";
import ProcessMaps from "./pages/ProcessMaps";
import ComingSoon from "./pages/ComingSoon";

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

        {/* Requires token + selected company */}
        <Route element={<AppLayout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          {/* Platform Navigation */}
          <Route path="/organisation" element={<ComingSoon />} />
          <Route path="/contacts" element={<ComingSoon />} />
          <Route path="/documents" element={<Documents />} />
          <Route path="/share-documents" element={<ComingSoon />} />
          <Route path="/product-analysis" element={<ComingSoon />} />
          <Route path="/processes" element={<Processes />} />
          <Route path="/process-maps" element={<ProcessMaps />} />
          <Route path="/assessments" element={<ComingSoon />} />
          <Route path="/audits" element={<ComingSoon />} />
          <Route path="/reports" element={<ComingSoon />} />
          <Route path="/invites" element={<ComingSoon />} />
          {/* Resources */}
          <Route path="/regulations" element={<ComingSoon />} />
          <Route path="/companies" element={<ComingSoon />} />
          {/* Settings */}
          <Route path="/settings" element={<ComingSoon />} />
        </Route>
      </Route>

      <Route
        path="*"
        element={<Navigate to={token ? "/select-company" : "/login"} replace />}
      />
    </Routes>
  );
}
