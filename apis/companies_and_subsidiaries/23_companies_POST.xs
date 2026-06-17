// Add companies record
query companies verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "companies"
    }
  }

  stack {
    db.add companies {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $companies
  }

  response = $companies
}