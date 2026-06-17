query user_email_exists verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text email? filters=trim
    text id? filters=trim
  }

  stack {
    db.query user {
      where = ($db.user.email|to_lower) == ($input.email|to_lower) && $db.user.id != $input.id
      return = {type: "exists"}
    } as $user_1
  }

  response = $user_1
}