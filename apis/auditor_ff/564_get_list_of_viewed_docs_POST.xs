query getListOfViewedDocs verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    conditional {
      if ($audit1.documents|is_empty) {
        var.update $audit1 {
          value = []
        }
      }
    
      else {
        var.update $audit1 {
          value = $audit1.documents.document
        }
      }
    }
  }

  response = {viewedDocs: $audit1}
}