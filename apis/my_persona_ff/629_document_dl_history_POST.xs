query documentDLHistory verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int document?
  }

  stack {
    db.query myPersonaDocumentsDownloadLog {
      where = $db.myPersonaDocumentsDownloadLog.document == $input.document
      return = {type: "list"}
      addon = [
        {
          name : "user"
          input: {user_id: $output.user}
          as   : "userDetails"
        }
        {
          name : "companies"
          input: {companies_id: $output.company}
          as   : "companyDetails"
        }
      ]
    } as $myPersonaDocumentsDownloadLog1
  }

  response = $myPersonaDocumentsDownloadLog1
}