query getAllFunctions verb=GET {
  api_group = "Sign Up FF"

  input {
  }

  stack {
    db.query functions {
      sort = {functions.function: "asc"}
      return = {type: "list"}
    } as $functions1
  }

  response = $functions1
}