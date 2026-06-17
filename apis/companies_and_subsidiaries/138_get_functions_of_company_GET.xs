query get_functions_of_company verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company_id
      output = ["functions", "functions_inactive"]
      addon = [
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions"
        }
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions_inactive"
        }
      ]
    } as $companies_1
  }

  response = $companies_1
}