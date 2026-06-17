// Delete countries record.
query "countries/{countries_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int countries_id? filters=min:1
  }

  stack {
    db.del "" {
      field_name = "id"
      field_value = $input.countries_id
    }
  }

  response = null
}