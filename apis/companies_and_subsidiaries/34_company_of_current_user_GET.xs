query company_of_current_user verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text user_id? filters=trim
  }

  stack {
    db.get companies {
      field_name = "created_by_user"
      field_value = $input.user_id
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_code"
        }
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          addon: [
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "created_by_user"
        }
      ]
    } as $companies_2
  }

  response = $companies_2
}