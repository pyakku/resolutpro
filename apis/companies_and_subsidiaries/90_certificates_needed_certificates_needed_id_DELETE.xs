// Delete certificates_needed record.
query "certificates_needed/{certificates_needed_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int certificates_needed_id? filters=min:1
  }

  stack {
    db.del certificates_needed {
      field_name = "id"
      field_value = $input.certificates_needed_id
    }
  }

  response = null
}