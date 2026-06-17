query edit_policy verb=POST {
  api_group = "p3dashboard"

  input {
    dblink {
      table = "policies"
      override = {
        desc      : {hidden: false}
        name      : {hidden: false}
        created_at: {hidden: true}
      }
    }
  
    text id? filters=trim
  }

  stack {
    db.edit policies {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {name: $input.name, desc: $input.desc}
    } as $policies_1
  
    db.query policies {
      sort = {policies.name: "asc"}
      return = {type: "list"}
    } as $policies_2
  }

  response = $policies_2
}