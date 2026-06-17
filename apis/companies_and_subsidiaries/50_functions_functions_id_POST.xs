// Edit functions record
query "functions/{functions_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int functions_id? filters=min:1
    dblink {
      table = "functions"
    }
  }

  stack {
    db.edit functions {
      field_name = "id"
      field_value = $input.functions_id
      enforce_hidden_fields = false
      data = {}
    } as $functions
  }

  response = $functions
}