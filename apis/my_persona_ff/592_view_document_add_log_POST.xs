query viewDocumentAddLog verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int document?
    int company?
  }

  stack {
    db.add myPersonaDocumentsViewLog {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        user      : $auth.id
        document  : $input.document
        company   : $input.company
      }
    } as $myPersonaDocumentsViewLog1
  }

  response = $myPersonaDocumentsViewLog1
}