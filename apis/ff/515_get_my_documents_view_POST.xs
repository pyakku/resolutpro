// Get All Documents of the current User
query getMyDocumentsView verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
    int documentClassification?
    int viewingCompany?
  }

  stack {
    conditional {
      if ($input.documentClassification == 0) {
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
      }
    
      else {
        db.query documents {
          where = $db.documents.documentClassification == $input.documentClassification
          return = {type: "list"}
        } as $documents1
      
        var.update $documents1 {
          value = $documents1.id
        }
      
        db.query myDocuments {
          where = $db.myDocuments.company == $input.company && $db.myDocuments.active == true && $db.myDocuments.document in $documents1
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
      }
    }
  
    conditional {
      if ($myDocuments1|is_empty) {
      }
    
      else {
        conditional {
          if ($input.viewingCompany == $input.company) {
            group {
              stack {
                var $temp {
                  value = []
                }
              
                foreach ($myDocuments1) {
                  each as $item {
                    var.update $temp {
                      value = $temp
                        |push:($item|set:"viewPermission":true)
                    }
                  }
                }
              
                var.update $myDocuments1 {
                  value = $temp
                }
              }
            }
          }
        
          else {
            group {
              stack {
                var $temp {
                  value = []
                }
              
                foreach ($myDocuments1) {
                  each as $item {
                    db.query documentPermissions {
                      where = $db.documentPermissions.myDocument == $item.id && $db.documentPermissions.company == $input.viewingCompany
                      return = {type: "exists"}
                    } as $documentPermissions1
                  
                    var.update $temp {
                      value = $temp
                        |push:($item
                          |set:"viewPermission":$documentPermissions1
                        )
                    }
                  }
                }
              
                var.update $myDocuments1 {
                  value = $temp
                }
              }
            }
          }
        }
      }
    }
  }

  response = $myDocuments1
}