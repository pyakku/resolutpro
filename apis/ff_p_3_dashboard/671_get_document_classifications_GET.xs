query getDocumentClassifications verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query documentClassification {
      sort = {documentClassification.classification: "asc"}
      return = {type: "list"}
    } as $document_types1
  
    conditional {
      if ($document_types1|is_empty) {
      }
    
      else {
        var $x1 {
          value = []
        }
      
        foreach ($document_types1) {
          each as $item {
            db.query documents {
              where = $db.documents.documentClassification == $item.id
              return = {type: "count"}
            } as $documents1
          
            var.update $x1 {
              value = $x1
                |push:($item|set:"count":$documents1)
            }
          }
        }
      
        var.update $document_types1 {
          value = $x1
        }
      }
    }
  }

  response = $document_types1
}