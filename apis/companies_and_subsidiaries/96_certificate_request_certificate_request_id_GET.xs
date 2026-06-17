// Get certificate_request record
query "certificate_request/{certificate_request_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int certificate_request_id? filters=min:1
  }

  stack {
    db.get certificate_request {
      field_name = "id"
      field_value = $input.certificate_request_id
    } as $certificate_request
  
    precondition ($certificate_request != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $certificate_request
}