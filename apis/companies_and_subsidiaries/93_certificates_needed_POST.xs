// Add certificates_needed record
query certificates_needed verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "certificates_needed"
    }
  }

  stack {
    db.add certificates_needed {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $certificates_needed
  }

  response = $certificates_needed
}