// Edit certificates record
query "certificates/{certificates_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int certificates_id? filters=min:1
    dblink {
      table = "certificates"
    }
  }

  stack {
    db.edit certificates {
      field_name = "id"
      field_value = $input.certificates_id
      enforce_hidden_fields = false
      data = {}
    } as $certificates
  }

  response = $certificates
}