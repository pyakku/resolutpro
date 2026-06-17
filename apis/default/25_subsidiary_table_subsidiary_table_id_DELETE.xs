// Delete subsidiary_table record.
query "subsidiary_table/{subsidiary_table_id}" verb=DELETE {
  api_group = "Default"

  input {
    int subsidiary_table_id? filters=min:1
  }

  stack {
    db.del subsidiary_table {
      field_name = "id"
      field_value = $input.subsidiary_table_id
    }
  }

  response = null
}