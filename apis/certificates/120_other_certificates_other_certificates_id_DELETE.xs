// Delete other_certificates record.
query "other_certificates/{other_certificates_id}" verb=DELETE {
  api_group = "Certificates"

  input {
    int other_certificates_id? filters=min:1
  }

  stack {
    db.del other_certificates {
      field_name = "id"
      field_value = $input.other_certificates_id
    }
  }

  response = null
}