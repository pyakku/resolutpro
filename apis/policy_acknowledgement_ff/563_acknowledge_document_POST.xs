query acknowledgeDocument verb=POST {
  api_group = "Policy Acknowledgement FF"
  auth = "user"

  input {
    int ackID?
  }

  stack {
    db.get documentAcknowledgement {
      field_name = "id"
      field_value = $input.ackID
    } as $documentAcknowledgement1
  
    var $myDocumentID {
      value = $documentAcknowledgement1.myDocument
    }
  
    var $acknowledgingCompany {
      value = $documentAcknowledgement1.acknowlegedBy
    }
  
    db.query documentAcknowledgement {
      where = $db.documentAcknowledgement.myDocument == $myDocumentID && $db.documentAcknowledgement.acknowlegedBy == $acknowledgingCompany && $db.documentAcknowledgement.acknowledged == false
      return = {type: "list"}
    } as $documentAcknowledgement2
  
    foreach ($documentAcknowledgement2) {
      each as $item {
        db.edit documentAcknowledgement {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {acknowledged: true, ackDate: now}
        } as $documentAcknowledgement3
      }
    }
  }

  response = $documentAcknowledgement1
}