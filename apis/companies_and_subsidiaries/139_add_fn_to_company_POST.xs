query add_fn_to_company verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
    int[] functions_id? {
      table = "functions"
    }
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.company_id
      enforce_hidden_fields = false
      data = {functions: $input.functions_id}
    } as $companies_1
  }

  response = $companies_1
}