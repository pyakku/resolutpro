query changePassword verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text password? filters=trim
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      enforce_hidden_fields = false
      data = {password: $input.password}
    } as $user1
  }

  response = $user1
}