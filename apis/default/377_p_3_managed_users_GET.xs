// Query all p3_managed_users records
query p3_managed_users verb=GET {
  api_group = "Default"

  input {
  }

  stack {
    db.query p3_managed_users {
      return = {type: "list"}
    } as $p3_managed_users
  }

  response = $p3_managed_users
}