query pending_policy_validation verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query my_policies {
      where = $db.my_policies.validation_date == null
      return = {type: "list"}
      addon = [
        {
          name : "policies"
          input: {policies_id: $output.policies_id}
          as   : "policies_id"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
      ]
    } as $my_policies_1
  }

  response = $my_policies_1
}