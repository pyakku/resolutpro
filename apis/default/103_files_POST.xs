// Add files record
query files verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "files"
    }
  }

  stack {
    db.add files {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $files
  }

  response = $files
}