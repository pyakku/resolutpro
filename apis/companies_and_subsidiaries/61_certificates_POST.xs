// Add certificates record
query certificates verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "certificates"
    }
  }

  stack {
    db.add certificates {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $certificates
  }

  response = $certificates
}