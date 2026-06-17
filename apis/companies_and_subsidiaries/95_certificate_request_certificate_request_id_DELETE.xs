// Delete certificate_request record.
query "certificate_request/{certificate_request_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int certificate_request_id? filters=min:1
  }

  stack {
    db.del certificate_request {
      field_name = "id"
      field_value = $input.certificate_request_id
    }
  }

  response = null
}