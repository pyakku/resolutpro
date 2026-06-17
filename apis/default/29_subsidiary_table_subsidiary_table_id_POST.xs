// Edit subsidiary_table record
query "subsidiary_table/{subsidiary_table_id}" verb=POST {
  api_group = "Default"

  input {
    int subsidiary_table_id? filters=min:1
    dblink {
      table = "subsidiary_table"
    }
  }

  stack {
    db.edit subsidiary_table {
      field_name = "id"
      field_value = $input.subsidiary_table_id
      enforce_hidden_fields = false
      data = {}
    } as $subsidiary_table
  }

  response = $subsidiary_table
}