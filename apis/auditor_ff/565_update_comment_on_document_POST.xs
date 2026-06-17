query updateCommentOnDocument verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
    int myDocumentID?
    text comment? filters=trim
    text status? filters=trim
  }

  stack {
    conditional {
      if ($input.status == "Checked") {
        var $approved {
          value = true
        }
      }
    
      else {
        var $approved {
          value = false
        }
      }
    }
  
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    conditional {
      if ($audit1.documents|is_empty) {
        db.edit audit {
          field_name = "id"
          field_value = $input.auditID
          enforce_hidden_fields = false
          data = {
            documents: $audit1.documents|push:({}|set:"document":$input.myDocumentID|set:"comment":$input.comment|set:"viewedOn":now|set:"rejected":($approved|not)|set:"approved":$approved)
          }
        } as $audit2
      }
    
      else {
        conditional {
          if ($audit1.documents.document|in:$input.myDocumentID) {
            db.edit audit {
              field_name = "id"
              field_value = $input.auditID
              enforce_hidden_fields = false
              data = {
                documents: $audit1.documents|remove:$input.myDocumentID:"document":false|push:({}|set:"document":$input.myDocumentID|set:"comment":$input.comment|set:"viewedOn":now|set:"rejected":($approved|not)|set:"approved":$approved)
              }
            } as $audit2
          }
        
          else {
            db.edit audit {
              field_name = "id"
              field_value = $input.auditID
              enforce_hidden_fields = false
              data = {
                documents: $audit1.documents|push:({}|set:"document":$input.myDocumentID|set:"comment":$input.comment|set:"viewedOn":now|set:"rejected":($approved|not)|set:"approved":$approved)
              }
            } as $audit2
          }
        }
      }
    }
  }

  response = $approved
}