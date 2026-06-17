// Query all files records
query files verb=GET {
  api_group = "Default"

  input {
  }

  stack {
    db.query files {
      return = {type: "list"}
    } as $files
  }

  response = $files
}