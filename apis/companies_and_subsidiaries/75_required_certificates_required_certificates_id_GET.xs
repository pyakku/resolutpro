// Get required_certificates record
query "required_certificates/{required_certificates_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int required_certificates_id? filters=min:1
  }

  stack {
    db.get required_certificates {
      field_name = "id"
      field_value = $input.required_certificates_id
    } as $required_certificates
  
    precondition ($required_certificates != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $required_certificates
}