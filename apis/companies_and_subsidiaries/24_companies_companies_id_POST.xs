// Edit companies record
query "companies/{companies_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int companies_id? filters=min:1
    dblink {
      table = "companies"
    }
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.companies_id
      enforce_hidden_fields = false
      data = {}
    } as $companies
  }

  response = $companies
}