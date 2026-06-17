query get_company_list_for_update verb=POST {
  api_group = "p3dashboard"

  input {
    timestamp? created_at?
  }

  stack {
    db.query companies {
      where = $db.companies.created_at > $input.created_at
      return = {type: "list"}
    } as $companies_1
  }

  response = $companies_1
}