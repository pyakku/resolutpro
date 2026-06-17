// Edit required_certificates record
query "required_certificates/{required_certificates_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int required_certificates_id? filters=min:1
    dblink {
      table = "required_certificates"
    }
  }

  stack {
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.required_certificates_id
      enforce_hidden_fields = false
      data = {}
    } as $required_certificates
  }

  response = $required_certificates
}