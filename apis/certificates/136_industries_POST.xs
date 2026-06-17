// Add industries record
query industries verb=POST {
  api_group = "Certificates"

  input {
    dblink {
      table = "industries"
    }
  }

  stack {
    db.add industries {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $industries
  }

  response = $industries
}