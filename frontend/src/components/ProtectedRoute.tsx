import { Navigate, Outlet } from "react-router-dom";
import { useAuthStore } from "../store/auth";

/** Gate for routes that require a signed-in user. */
export default function ProtectedRoute() {
  const token = useAuthStore((s) => s.token);
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return <Outlet />;
}
