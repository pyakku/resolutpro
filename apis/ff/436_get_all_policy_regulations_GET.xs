query get_all_policy_regulations verb=GET {
  api_group = "ff"
  auth = "user"

  input {
  }

  stack {
    db.query policies {
      return = {type: "list"}
    } as $policies1
  }

  response = $policies1
}