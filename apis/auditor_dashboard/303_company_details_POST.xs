query company_details verb=POST {
  api_group = "auditor_dashboard"

  input {
    text company? filters=trim
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
      addon = [
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions"
        }
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "created_by_user"
        }
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_code"
        }
      ]
    } as $companies_1
  }

  response = $companies_1
}