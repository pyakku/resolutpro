// Delete files record.
query "files/{files_id}" verb=DELETE {
  api_group = "Default"

  input {
    int files_id? filters=min:1
  }

  stack {
    db.del files {
      field_name = "id"
      field_value = $input.files_id
    }
  }

  response = null
}