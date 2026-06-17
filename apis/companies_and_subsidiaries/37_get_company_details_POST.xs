query get_company_details verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company_reg? filters=trim
  }

  stack {
    db.query companies {
      where = $db.companies.created_by_user == $input.company_reg
      return = {type: "list"}
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