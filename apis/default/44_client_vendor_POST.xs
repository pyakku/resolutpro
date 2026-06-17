// Add client_vendor record
query client_vendor verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "relationships"
    }
  }

  stack {
    db.add relationships {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $client_vendor
  }

  response = $client_vendor
}