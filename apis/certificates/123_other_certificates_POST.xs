// Add other_certificates record
query other_certificates verb=POST {
  api_group = "Certificates"

  input {
    dblink {
      table = "other_certificates"
    }
  }

  stack {
    db.add other_certificates {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $other_certificates
  }

  response = $other_certificates
}