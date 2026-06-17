query validate_email verb=POST {
  api_group = "sign_upv3"

  input {
    text email? filters=trim
  }

  stack {
    db.has user {
      field_name = "email"|to_lower
      field_value = $input.email|to_lower
    } as $user_1
  }

  response = $user_1
}