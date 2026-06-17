// Get client_vendor record
query "client_vendor/{client_vendor_id}" verb=GET {
  api_group = "Default"

  input {
    int client_vendor_id? filters=min:1
  }

  stack {
    db.get relationships {
      field_name = "id"
      field_value = $input.client_vendor_id
    } as $client_vendor
  
    precondition ($client_vendor != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $client_vendor
}