// Edit certificate_request record
query "certificate_request/{certificate_request_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int certificate_request_id? filters=min:1
    dblink {
      table = "certificate_request"
    }
  }

  stack {
    db.edit certificate_request {
      field_name = "id"
      field_value = $input.certificate_request_id
      enforce_hidden_fields = false
      data = {}
    } as $certificate_request
  }

  response = $certificate_request
}