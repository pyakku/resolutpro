query policy_page_load verb=POST {
  api_group = "policies"

  input {
    text company? filters=trim
  }

  stack {
    db.query policies {
      return = {type: "list"}
    } as $policies_1
  
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

  response = {policy_list: $policies_1, my_policies: $my_policies_1}
}