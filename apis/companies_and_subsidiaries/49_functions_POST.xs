// Add functions record
query functions verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "functions"
    }
  }

  stack {
    db.add functions {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $functions
  }

  response = $functions
}