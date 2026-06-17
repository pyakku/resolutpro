query GET_ALL_USERS verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query user {
      return = {type: "list"}
      output = ["id", "name", "l_name", "email", "is_admin", "business_dev"]
    } as $user_1
  }

  response = $user_1
}