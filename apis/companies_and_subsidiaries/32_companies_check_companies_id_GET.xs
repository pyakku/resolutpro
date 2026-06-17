query "companies_check/{companies_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.has companies {
      field_name = "company_reg"
      field_value = $input.company_id
    } as $companies_1
  }

  response = $companies_1
}