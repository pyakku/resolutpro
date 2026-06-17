query get_business_dev_users verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query user {
      where = $db.user.business_dev == true
      sort = {user.name: "asc", user.l_name: "asc"}
      return = {type: "list"}
    } as $user_1
  }

  response = $user_1
}