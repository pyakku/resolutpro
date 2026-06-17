query uploadfile verb=POST {
  api_group = "Default"

  input {
    file content?
  }

  stack {
    storage.create_attachment {
      value = $input.content
      access = "public"
    } as $attachment
  
    db.add files {
      enforce_hidden_fields = false
      data = {created_at: "now", files: $attachment}
    } as $files_1
  }

  response = $files_1
}