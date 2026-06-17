query editDocument verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    text name? filters=trim
    timestamp? expiryDate?
    timestamp? issueDate?
    int mydocumentID?
    text mypersonaClassification? filters=trim
  }

  stack {
    db.edit myDocuments {
      field_name = "id"
      field_value = $input.mydocumentID
      enforce_hidden_fields = false
      data = {
        nameUA                 : $input.name
        issueDate              : $input.issueDate
        expiryDate             : $input.expiryDate
        validated              : "false"
        rejected               : false
        active                 : true
        archived               : false
        mypersonaClassification: $input.mypersonaClassification
      }
    } as $myDocuments1
  }

  response = $myDocuments1
}