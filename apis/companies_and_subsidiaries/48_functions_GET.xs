// Query all functions records
query functions verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query functions {
      sort = {functions.function: "asc"}
      return = {type: "list"}
    } as $functions
  }

  response = $functions
}