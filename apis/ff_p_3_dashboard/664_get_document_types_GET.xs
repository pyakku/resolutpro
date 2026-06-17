query getDocumentTypes verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query document_types {
      sort = {document_types.type: "asc"}
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
              where = $db.documents.documentType == $item.id
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