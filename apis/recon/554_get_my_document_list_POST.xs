query getMyDocumentList verb=POST {
  api_group = "Recon"
  auth = "user"

  input {
    int[] documents?
  }

  stack {
    conditional {
      if (($input.documents|count) != 0) {
        var $docList {
          value = []
        }
      
        foreach ($input.documents) {
          each as $item {
            db.get myDocuments {
              field_name = "id"
              field_value = $item
              addon = [
                {
                  name : "documents"
                  input: {documents_id: $output.document}
                  as   : "document"
                }
              ]
            } as $myDocuments1
          
            var.update $docList {
              value = $docList|push:$myDocuments1
            }
          }
        }
      }
    
      else {
        var $docList {
          value = []
        }
      }
    }
  }

  response = $docList
}