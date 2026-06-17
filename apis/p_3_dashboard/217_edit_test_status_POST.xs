query edit_test_status verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
    bool status?=false
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {test: $input.status}
    } as $companies_2
  
    db.query companies {
      return = {type: "list"}
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
        {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
      ]
    } as $companies_1
  }

  response = $companies_1
}