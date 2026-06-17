query add_policy verb=POST {
  api_group = "p3dashboard"

  input {
    dblink {
      table = "policies"
      override = {
        desc       : {hidden: false}
        name       : {hidden: false}
        created_at : {hidden: true}
        requirement: {hidden: true}
      }
    }
  }

  stack {
    db.add policies {
      enforce_hidden_fields = false
      data = {name: $input.name, desc: $input.desc}
    } as $policies_1
  
    db.query policies {
      return = {type: "list"}
    } as $policies_2
  }

  response = $policies_2
}