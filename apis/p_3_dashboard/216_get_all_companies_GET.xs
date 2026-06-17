query get_all_companies verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
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