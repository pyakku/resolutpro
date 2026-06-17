query approve_client_vendor_relationship verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    bool approval?=false
    text id? filters=trim
  }

  stack {
    db.edit relationships {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {approved: $input.approval}
    } as $client_vendor_1
  }

  response = $client_vendor_1
}