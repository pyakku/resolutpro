query my_policies verb=POST {
  api_group = "auditor_dashboard"

  input {
    text company? filters=trim
  }

  stack {
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "policies"
          input: {policies_id: $output.policies_id}
          as   : "policies_id"
        }
      ]
    } as $my_policies_1
  }

  response = $my_policies_1
}