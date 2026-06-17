query reset_password verb=POST {
  api_group = "Default"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.edit user {
      field_name = "email"
      field_value = $input.email
      enforce_hidden_fields = false
      data = {password: $input.password}
      output = [
        "id"
        "created_at"
        "name"
        "l_name"
        "email"
        "user_id"
        "language"
        "date_format"
        "is_admin"
        "plan"
      ]
    } as $user_1
  }

  response = $user_1
}