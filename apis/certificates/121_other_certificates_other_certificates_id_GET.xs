// Get other_certificates record
query "other_certificates/{other_certificates_id}" verb=GET {
  api_group = "Certificates"

  input {
    int other_certificates_id? filters=min:1
  }

  stack {
    db.get other_certificates {
      field_name = "id"
      field_value = $input.other_certificates_id
    } as $other_certificates
  
    precondition ($other_certificates != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $other_certificates
}