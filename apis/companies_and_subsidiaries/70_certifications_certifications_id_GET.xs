// Get certifications record
query "certifications/{certifications_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int certifications_id? filters=min:1
  }

  stack {
    db.get "" {
      field_name = "id"
      field_value = $input.certifications_id
    } as $certifications
  
    precondition ($certifications != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $certifications
}