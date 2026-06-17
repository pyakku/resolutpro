// Edit other_certificates record
query "other_certificates/{other_certificates_id}" verb=POST {
  api_group = "Certificates"

  input {
    int other_certificates_id? filters=min:1
    dblink {
      table = "other_certificates"
    }
  }

  stack {
    db.edit other_certificates {
      field_name = "id"
      field_value = $input.other_certificates_id
      enforce_hidden_fields = false
      data = {}
    } as $other_certificates
  }

  response = $other_certificates
}