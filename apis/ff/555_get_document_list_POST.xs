query getDocumentList verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int[] documentList?
  }

  stack {
    conditional {
      if ($input.documentList|is_empty) {
        var $output {
          value = []
        }
      }
    
      else {
        var $output {
          value = []
        }
      
        foreach ($input.documentList) {
          each as $item {
            db.get myDocuments {
              field_name = "id"
              field_value = $item
              addon = [
                {
                  name  : "documents"
                  output: ["documentName", "logo.url"]
                  input : {documents_id: $output.document}
                }
              ]
            } as $myDocuments1
          
            var.update $output {
              value = $var.output|push:$myDocuments1
            }
          }
        }
      }
    }
  }

  response = $var.output
}