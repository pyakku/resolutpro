// Get countries record
query "countries/{countries_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int countries_id? filters=min:1
  }

  stack {
    db.get "" {
      field_name = "id"
      field_value = $input.countries_id
    } as $countries
  
    precondition ($countries != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $countries
}