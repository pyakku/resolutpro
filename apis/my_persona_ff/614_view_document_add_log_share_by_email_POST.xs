query viewDocumentAddLogShareByEmail verb=POST {
  api_group = "myPersonaFF"

  input {
    int document?
    text email? filters=trim
  }

  stack {
    db.add myPersonaDocumentsViewLog {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        document  : $input.document
        email     : $input.email
      }
    } as $myPersonaDocumentsViewLog1
  }

  response = $myPersonaDocumentsViewLog1
}