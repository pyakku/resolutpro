query checkPassword verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text password? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
        "created_at"
        "name"
        "l_name"
        "email"
        "password"
        "user_id"
        "profile_img"
        "language"
        "date_format"
        "is_admin"
        "plan"
        "business_dev"
        "completed_walkthrough"
      ]
    } as $user1
  
    security.check_password {
      text_password = $input.password
      hash_password = $user1.password
    } as $x1
  }

  response = {correct: $x1}
}