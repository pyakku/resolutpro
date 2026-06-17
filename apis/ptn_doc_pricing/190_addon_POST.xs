query addon verb=POST {
  api_group = "ptn&doc pricing"

  input {
    text type? filters=trim
    int company_id?
    int plan?
  }

  stack {
    function.run addon_to_subscription {
      input = {
        plan      : $input.plan
        type      : $input.type
        company_id: $input.company_id
      }
    } as $func_1
  }

  response = $func_1
}