query check_contact verb=POST {
  api_group = "Certificates"

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