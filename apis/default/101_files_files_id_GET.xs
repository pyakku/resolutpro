// Get files record
query "files/{files_id}" verb=GET {
  api_group = "Default"

  input {
    int files_id? filters=min:1
  }

  stack {
    db.get files {
      field_name = "id"
      field_value = $input.files_id
    } as $files
  
    precondition ($files != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $files
}