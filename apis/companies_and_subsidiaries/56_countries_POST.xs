// Add countries record
query countries verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = ""
    }
  }

  stack {
    db.add "" {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $countries
  }

  response = $countries
}