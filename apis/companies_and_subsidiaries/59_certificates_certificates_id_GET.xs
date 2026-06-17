// Get certificates record
query "certificates/{certificates_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int certificates_id? filters=min:1
  }

  stack {
    db.get certificates {
      field_name = "id"
      field_value = $input.certificates_id
    } as $certificates
  
    precondition ($certificates != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $certificates
}