// Delete certificates record.
query "certificates/{certificates_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int certificates_id? filters=min:1
  }

  stack {
    db.del certificates {
      field_name = "id"
      field_value = $input.certificates_id
    }
  }

  response = null
}