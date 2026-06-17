query policy_list verb=POST {
  api_group = "Reports_Page"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company_id
      sort = {my_policies.date: "asc"}
      return = {type: "list"}
      addon = [
        {
          name  : "policies"
          output: ["name"]
          input : {policies_id: $output.policies_id}
        }
      ]
    } as $my_policies_1
  }

  response = $my_policies_1
}