// Get certificates_needed record
query "certificates_needed/{certificates_needed_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int certificates_needed_id? filters=min:1
  }

  stack {
    db.get certificates_needed {
      field_name = "id"
      field_value = $input.certificates_needed_id
    } as $certificates_needed
  
    precondition ($certificates_needed != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $certificates_needed
}