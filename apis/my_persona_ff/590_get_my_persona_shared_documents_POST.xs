query getMyPersonaSharedDocuments verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query myPersonaShare {
      where = $db.myPersonaShare.company == $input.company && $db.myPersonaShare.active == true && $db.myPersonaShare.approvedByReciepent == true
      sort = {myPersonaShare.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.myDocument}
          addon: [
            {
              name : "contacts"
              input: {contacts_id: $output.holderContact}
              as   : "holderContact"
            }
          ]
          as   : "document"
        }
      ]
    } as $myPersonaShare1
  
    conditional {
      if (($myPersonaShare1|is_empty) == false) {
        var.update $myPersonaShare1 {
          value = $myPersonaShare1.document
        }
      }
    }
  }

  response = $myPersonaShare1
}