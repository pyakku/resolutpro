query get_policies verb=GET {
  api_group = "p3dashboard"

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