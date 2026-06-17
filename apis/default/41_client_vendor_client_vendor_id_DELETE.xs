// Delete client_vendor record.
query "client_vendor/{client_vendor_id}" verb=DELETE {
  api_group = "Default"

  input {
    int client_vendor_id? filters=min:1
  }

  stack {
    db.del relationships {
      field_name = "id"
      field_value = $input.client_vendor_id
    }
  }

  response = null
}