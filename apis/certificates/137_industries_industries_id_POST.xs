// Edit industries record
query "industries/{industries_id}" verb=POST {
  api_group = "Certificates"

  input {
    int industries_id? filters=min:1
    dblink {
      table = "industries"
    }
  }

  stack {
    db.edit industries {
      field_name = "id"
      field_value = $input.industries_id
      enforce_hidden_fields = false
      data = {}
    } as $industries
  }

  response = $industries
}