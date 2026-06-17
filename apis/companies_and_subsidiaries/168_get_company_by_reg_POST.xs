query get_company_by_reg verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text reg? filters=trim
  }

  stack {
    db.get companies {
      field_name = "company_reg"
      field_value = $input.reg
      addon = [
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "created_by_user"
        }
      ]
    } as $companies_1
  }

  response = $companies_1
}