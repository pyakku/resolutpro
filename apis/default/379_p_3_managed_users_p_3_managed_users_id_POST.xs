// Edit p3_managed_users record
query "p3_managed_users/{p3_managed_users_id}" verb=POST {
  api_group = "Default"

  input {
    int p3_managed_users_id? filters=min:1
    dblink {
      table = "p3_managed_users"
    }
  }

  stack {
    db.edit p3_managed_users {
      field_name = "id"
      field_value = $input.p3_managed_users_id
      enforce_hidden_fields = false
      data = {}
    } as $p3_managed_users
  }

  response = $p3_managed_users
}