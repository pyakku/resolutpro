query "roles/getall" verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.query "myPersona Roles" {
      sort = {myPersona_Roles.id: "asc"}
      return = {type: "list"}
      output = ["role"]
    } as $myPersona_Roles1
  }

  response = $myPersona_Roles1
}