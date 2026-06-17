// Add required_certificates record
query required_certificates verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "required_certificates"
    }
  }

  stack {
    db.add required_certificates {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $required_certificates
  }

  response = $required_certificates
}