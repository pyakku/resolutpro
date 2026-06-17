// Edit client_vendor record
query "client_vendor/{client_vendor_id}" verb=POST {
  api_group = "Default"

  input {
    int client_vendor_id? filters=min:1
    dblink {
      table = "relationships"
    }
  }

  stack {
    db.edit relationships {
      field_name = "id"
      field_value = $input.client_vendor_id
      enforce_hidden_fields = false
      data = {}
    } as $client_vendor
  }

  response = $client_vendor
}