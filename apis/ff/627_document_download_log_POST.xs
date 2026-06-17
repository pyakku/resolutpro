query documentDownloadLog verb=POST {
  api_group = "ff"

  input {
    int myDocument?
    text email? filters=trim
  }

  stack {
    db.add myPersonaDocumentsDownloadLog {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        document  : $input.myDocument
        email     : $input.email
      }
    } as $myPersonaDocumentsDownloadLog1
  }

  response = $myPersonaDocumentsDownloadLog1
}