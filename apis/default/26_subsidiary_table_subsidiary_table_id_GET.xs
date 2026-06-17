// Get subsidiary_table record
query "subsidiary_table/{subsidiary_table_id}" verb=GET {
  api_group = "Default"

  input {
    int subsidiary_table_id? filters=min:1
  }

  stack {
    db.get subsidiary_table {
      field_name = "id"
      field_value = $input.subsidiary_table_id
    } as $subsidiary_table
  
    precondition ($subsidiary_table != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $subsidiary_table
}