// Add p3_managed_users record
query p3_managed_users verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "p3_managed_users"
    }
  }

  stack {
    db.add p3_managed_users {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $p3_managed_users
  }

  response = $p3_managed_users
}