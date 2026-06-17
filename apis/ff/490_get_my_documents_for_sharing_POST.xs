// Get All Documents of the current User
query getMyDocumentsForSharing verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.company == $input.company && $db.myDocuments.active == true
      return = {type: "list"}
      addon = [
        {
          name : "documents"
          input: {documents_id: $output.document}
          addon: [
            {
              name  : "document_types"
              output: ["type"]
              input : {document_types_id: $output.documentType}
            }
            {
              name  : "documentClassification"
              output: ["classification"]
              input : {documentClassification_id: $output.documentClassification}
            }
          ]
          as   : "document"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.holder_company}
          as    : "holder_company"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holderContact}
          as   : "holderContact"
        }
      ]
    } as $myDocuments1
  
    conditional {
      if (($myDocuments1|is_empty) == false) {
        var $temp {
          value = []
        }
      
        foreach ($myDocuments1) {
          each as $item {
            conditional {
              if ($item.document == null || $item.document == 0) {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"selected":false
                      |set:"displayName":$item.nameUA
                    )
                }
              }
            
              else {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"selected":false
                      |set:"displayName":$item.document.documentName
                    )
                }
              }
            }
          }
        }
      
        var.update $myDocuments1 {
          value = $temp|sort:"displayName":"itext":true
        }
      }
    }
  }

  response = $myDocuments1
}