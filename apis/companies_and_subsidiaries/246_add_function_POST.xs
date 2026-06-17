query add_function verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text function? filters=trim
  }

  stack {
    db.add functions {
      enforce_hidden_fields = false
      data = {created_at: "now", function: $input.function}
    } as $functions_1
  
    db.query functions {
      return = {type: "list"}
    } as $functions_2
  }

  response = $functions_2
}