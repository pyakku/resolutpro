query get_all_policies verb=GET {
  api_group = "policies"

  input {
  }

  stack {
    db.query policies {
      sort = {policies.name: "asc"}
      return = {type: "list"}
    } as $policies_1
  }

  response = $policies_1
}