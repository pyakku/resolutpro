// Get the record belonging to the authentication token
query "auth/me" verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.get p3DashboardUser {
      field_name = "id"
      field_value = $auth.id
      output = ["id", "created_at", "email", "Name"]
    } as $p3DashboardUser
  }

  response = $p3DashboardUser
}