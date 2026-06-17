query get_policy_by_id verb=POST {
  api_group = "policies"

  input {
    text id? filters=trim
  }

  stack {
    db.get my_policies {
      field_name = "id"
      field_value = $input.id
    } as $my_policies_1
  }

  response = $my_policies_1
}