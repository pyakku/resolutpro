query current_company_subs verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    function.run current_company_subs {
      input = {company_id: $input.company_id}
    } as $func_1
  }

  response = $func_1
}