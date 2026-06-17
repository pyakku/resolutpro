query updateProfileGetFunctions verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int[] functions?
  }

  stack {
    db.query functions {
      where = $db.functions.id in $input.functions
      return = {type: "list"}
    } as $functions1
  }

  response = $functions1
}