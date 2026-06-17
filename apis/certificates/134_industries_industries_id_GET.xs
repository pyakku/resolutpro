// Get industries record
query "industries/{industries_id}" verb=GET {
  api_group = "Certificates"

  input {
    int industries_id? filters=min:1
  }

  stack {
    db.get industries {
      field_name = "id"
      field_value = $input.industries_id
    } as $industries
  
    precondition ($industries != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $industries
}