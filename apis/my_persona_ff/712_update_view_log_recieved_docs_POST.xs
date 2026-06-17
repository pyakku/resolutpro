query updateViewLogRecievedDocs verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int myDocumentID?
    text email? filters=trim
  }

  stack {
    db.get myDocuments {
      field_name = "id"
      field_value = $input.myDocumentID
    } as $myDocuments1
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get contacts {
      field_name = "email"
      field_value = $user1.email
    } as $contacts1
  
    db.query companies {
      where = $db.companies.created_by_user == $auth.id && $db.companies.individual == true
      return = {type: "single"}
    } as $companies1
  
    conditional {
      if ($myDocuments1.holderContact == $contacts1.id || $myDocuments1.company == $companies1.id) {
      }
    
      else {
        db.add myPersonaDocumentsViewLog {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            user      : $auth.id
            document  : $input.myDocumentID
            email     : $input.email
          }
        } as $myPersonaDocumentsViewLog1
      }
    }
  }

  response = "Done"
}