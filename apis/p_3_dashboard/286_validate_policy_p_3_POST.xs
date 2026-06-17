query validate_policy_p3 verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
    text user? filters=trim
  }

  stack {
    db.edit my_policies {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {validation_date: now, user: $input.user|to_int}
    } as $my_policies_2
  
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