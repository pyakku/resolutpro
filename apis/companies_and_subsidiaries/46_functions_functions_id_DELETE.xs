// Delete functions record.
query "functions/{functions_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int functions_id? filters=min:1
  }

  stack {
    db.del functions {
      field_name = "id"
      field_value = $input.functions_id
    }
  }

  response = null
}