query getMyPersonaDocumentsToConfirm verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query myPersonaShare {
      where = $db.myPersonaShare.company == $input.company && $db.myPersonaShare.active == true && $db.myPersonaShare.approvedByReciepent == false
      sort = {myPersonaShare.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.myDocument}
          addon: [
            {
              name  : "contacts"
              output: ["name", "l_name"]
              input : {contacts_id: $output.holderContact}
            }
          ]
          as   : "myDocumentDetails"
        }
      ]
    } as $myPersonaShare1
  }

  response = $myPersonaShare1
}