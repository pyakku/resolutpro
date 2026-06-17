// Get p3_managed_users record
query "p3_managed_users/{p3_managed_users_id}" verb=GET {
  api_group = "Default"

  input {
    int p3_managed_users_id? filters=min:1
  }

  stack {
    db.get p3_managed_users {
      field_name = "id"
      field_value = $input.p3_managed_users_id
    } as $p3_managed_users
  
    precondition ($p3_managed_users != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $p3_managed_users
}