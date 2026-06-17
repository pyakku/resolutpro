query get_name_from_email verb=POST {
  api_group = "sign_upv3"

  input {
    text email? filters=trim
  }

  stack {
    db.query user {
      where = $db.user.email == $input.email
      return = {type: "single"}
      output = ["name", "l_name"]
    } as $user_1
  }

  response = $user_1
}