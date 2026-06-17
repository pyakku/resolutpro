query allUsers verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.individual == true
      return = {type: "list"}
    } as $companies1
  
    db.query user {
      where = $db.user.id not in $companies1.created_by_user
      sort = {user.name: "asc", user.l_name: "asc"}
      return = {type: "list"}
    } as $user1
  }

  response = $user1
}