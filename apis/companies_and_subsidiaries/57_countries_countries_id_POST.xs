// Edit countries record
query "countries/{countries_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int countries_id? filters=min:1
    dblink {
      table = ""
    }
  }

  stack {
    db.edit "" {
      field_name = "id"
      field_value = $input.countries_id
      enforce_hidden_fields = false
      data = {}
    } as $countries
  }

  response = $countries
}