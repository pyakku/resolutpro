query get_company_details_single verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query companies {
      join = {
        user: {
          table: "user"
          type : "left"
          where: $db.companies.created_by == $db.user.user_id
        }
      }
    
      where = $db.companies.id == $input.company_id
      eval = {owner_name: $db.user.name, owner_l_name: $db.user.l_name}
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
          addon: [
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "created_by_user"
        }
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_code"
        }
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions_inactive"
        }
        {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
      ]
    } as $companies_1
  }

  response = $companies_1
}