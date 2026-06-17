query check_user_exists verb=GET {
  api_group = "Default"

  input {
    text email? filters=trim
  }

  stack {
    db.has user {
      field_name = "email"
      field_value = $input.email
    } as $user_1
  }

  response = $user_1
}