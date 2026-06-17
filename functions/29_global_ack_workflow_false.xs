function globalAckWorkflowFALSE {
  input {
    int myDocumentID?
    int owner?
  }

  stack {
    db.query relationships {
      where = $db.relationships.assigned_by == $input.owner
      return = {type: "list"}
    } as $relationships1
  
    conditional {
      if ($relationships1|is_empty) {
      }
    
      else {
        foreach ($relationships1) {
          each as $item {
            db.query documentAcknowledgement {
              where = $db.documentAcknowledgement.owner == $input.owner && $db.documentAcknowledgement.myDocument == $input.myDocumentID && $db.documentAcknowledgement.PTN == $item.PTN_no
              return = {type: "exists"}
            } as $recordExists
          
            conditional {
              if ($recordExists || $input.owner == $item.assigned_to) {
              }
            
              else {
                db.add documentAcknowledgement {
                  enforce_hidden_fields = false
                  data = {
                    created_at   : "now"
                    myDocument   : $input.myDocumentID
                    owner        : $input.owner
                    acknowlegedBy: $item.assigned_to
                    PTN          : $item.PTN_no
                  }
                } as $documentAcknowledgement1
              }
            }
          }
        }
      }
    }
  }

  response = null
}