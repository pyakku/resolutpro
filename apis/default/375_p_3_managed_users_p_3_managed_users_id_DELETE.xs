// Delete p3_managed_users record.
query "p3_managed_users/{p3_managed_users_id}" verb=DELETE {
  api_group = "Default"

  input {
    int p3_managed_users_id? filters=min:1
  }

  stack {
    db.del p3_managed_users {
      field_name = "id"
      field_value = $input.p3_managed_users_id
    }
  }

  response = null
}