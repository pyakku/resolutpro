// Get functions record
query "functions/{functions_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int functions_id? filters=min:1
  }

  stack {
    db.get functions {
      field_name = "id"
      field_value = $input.functions_id
    } as $functions
  
    precondition ($functions != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $functions
}