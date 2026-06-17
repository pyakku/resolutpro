query setDocumentPermissions verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int[] documents?
    int[] companies?
  }

  stack {
    foreach ($input.documents) {
      each as $doc {
        foreach ($input.companies) {
          each as $company {
            db.query documentPermissions {
              where = $db.documentPermissions.myDocument == $doc && $db.documentPermissions.company == $company
              return = {type: "exists"}
            } as $documentPermissions1
          
            conditional {
              if ($documentPermissions1) {
              }
            
              else {
                db.add documentPermissions {
                  enforce_hidden_fields = false
                  data = {
                    created_at: "now"
                    myDocument: $doc
                    company   : $company
                  }
                } as $documentPermissions2
              }
            }
          }
        }
      }
    }
  }

  response = {status: "done"}
}