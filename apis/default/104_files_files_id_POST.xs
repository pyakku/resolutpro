// Edit files record
query "files/{files_id}" verb=POST {
  api_group = "Default"

  input {
    int files_id? filters=min:1
    dblink {
      table = "files"
    }
  }

  stack {
    db.edit files {
      field_name = "id"
      field_value = $input.files_id
      enforce_hidden_fields = false
      data = {}
    } as $files
  }

  response = $files
}