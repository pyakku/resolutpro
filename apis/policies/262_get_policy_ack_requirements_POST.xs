query get_policy_ack_requirements verb=POST {
  api_group = "policies"

  input {
    text rel? filters=trim
  }

  stack {
    db.query policy_requirements {
      where = $db.policy_requirements.relationships_id == $input.rel
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.originator}
          as   : "originator"
        }
        {
          name : "my_policies"
          input: {my_policies_id: $output.my_policies_id}
          addon: [
            {
              name : "policies"
              input: {policies_id: $output.policies_id}
              as   : "policies"
            }
          ]
          as   : "my_policies_id"
        }
      ]
    } as $policy_requirements_1
  }

  response = $policy_requirements_1
}