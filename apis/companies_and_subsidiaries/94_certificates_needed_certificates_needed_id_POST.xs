// Edit certificates_needed record
query "certificates_needed/{certificates_needed_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int certificates_needed_id? filters=min:1
    dblink {
      table = "certificates_needed"
    }
  }

  stack {
    db.edit certificates_needed {
      field_name = "id"
      field_value = $input.certificates_needed_id
      enforce_hidden_fields = false
      data = {}
    } as $certificates_needed
  }

  response = $certificates_needed
}