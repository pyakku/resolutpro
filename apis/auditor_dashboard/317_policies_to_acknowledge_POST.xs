query policies_to_acknowledge verb=POST {
  api_group = "auditor_dashboard"

  input {
    text company? filters=trim
  }

  stack {
    db.query policy_requirements {
      where = $db.policy_requirements.assigned_to == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "my_policies"
          input: {my_policies_id: $output.my_policies_id}
          addon: [
            {
              name : "policies"
              input: {policies_id: $output.policies_id}
              as   : "policies_id"
            }
          ]
          as   : "my_policies_id"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.originator}
          as   : "originator"
        }
        {
          name : "relationships"
          input: {relationships_id: $output.relationships_id}
          addon: [
            {
              name : "companies"
              input: {companies_id: $output.assigned_by}
              as   : "assigned_by"
            }
          ]
          as   : "relationships_id"
        }
      ]
    } as $policy_requirements_1
  }

  response = $policy_requirements_1
}