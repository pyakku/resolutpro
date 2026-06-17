query documentViewHistory verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int document?
  }

  stack {
    db.query myPersonaDocumentsViewLog {
      where = $db.myPersonaDocumentsViewLog.document == $input.document && $db.myPersonaDocumentsViewLog.user != $auth.id
      return = {type: "list"}
      addon = [
        {
          name : "user"
          input: {user_id: $output.user}
          as   : "userDetails"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "companyDetails"
        }
      ]
    } as $myPersonaDocumentsViewLog1
  }

  response = $myPersonaDocumentsViewLog1
}