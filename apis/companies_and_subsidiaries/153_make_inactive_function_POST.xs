query make_inactive_function verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int[] functions_id?
    text company_id? filters=trim
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.company_id
      enforce_hidden_fields = false
      data = {functions_inactive: $input.functions_id}
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