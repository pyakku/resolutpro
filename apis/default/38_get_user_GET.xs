query get_user verb=GET {
  api_group = "Default"

  input {
    text user_id? filters=trim
  }

  stack {
    db.get user {
      field_name = "user_id"
      field_value = $input.user_id
      output = ["name", "l_name", "email", "profile_img"]
    } as $user_1
  }

  response = $user_1
}