// Delete companies record.
query "companies/{companies_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int companies_id? filters=min:1
  }

  stack {
    db.del companies {
      field_name = "id"
      field_value = $input.companies_id
    }
  }

  response = null
}