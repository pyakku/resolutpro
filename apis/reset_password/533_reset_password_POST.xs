query resetPassword verb=POST {
  api_group = "Reset Password"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.edit user {
      field_name = "email"
      field_value = $input.email|to_lower
      enforce_hidden_fields = false
      data = {password: $input.password}
    } as $user1
  }

  response = $user1
}