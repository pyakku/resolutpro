// Delete required_certificates record.
query "required_certificates/{required_certificates_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int required_certificates_id? filters=min:1
  }

  stack {
    db.del required_certificates {
      field_name = "id"
      field_value = $input.required_certificates_id
    }
  }

  response = null
}