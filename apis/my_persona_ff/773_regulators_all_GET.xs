query "regulators/all" verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.query regulator {
      return = {type: "list"}
      output = ["id", "name"]
    } as $regulator1
  }

  response = $regulator1
}