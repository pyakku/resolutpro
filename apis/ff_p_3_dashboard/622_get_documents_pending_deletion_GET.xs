query getDocumentsPendingDeletion verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.markedForDeletion == true
      return = {type: "list"}
      addon = [
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
        {
          name : "documents"
          input: {documents_id: $output.document}
          addon: [
            {
              name  : "documentClassification"
              output: ["classification"]
              input : {documentClassification_id: $output.documentClassification}
            }
            {
              name  : "document_types"
              output: ["type"]
              input : {document_types_id: $output.documentType}
            }
          ]
          as   : "document"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holderContact}
          as   : "holderContact"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.holder_company}
          as   : "holder_company"
        }
      ]
    } as $myDocuments1
  
    var.update $myDocuments1 {
      value = $myDocuments1
        |sort:"Company_Name":"itext":true
        |remove:true:"myPersona":false
    }
  
    !db.query myPersonaShare {
      where = $db.myPersonaShare.approvedByReciepent == true && $db.myPersonaShare.shareByEmail == false && $db.myPersonaShare.active == true
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.myDocument}
          addon: [
            {
              name  : "contacts"
              output: [
                "id"
                "created_at"
                "name"
                "l_name"
                "email"
                "phone_number"
                "created_by"
                "approved"
                "code"
              ]
              input : {contacts_id: $output.holderContact}
              as    : "holderContact"
            }
            {
              name : "companies"
              input: {companies_id: $output.holder_company}
              as   : "holder_company"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.company}
            }
          ]
          as   : "myDocument"
        }
      ]
    } as $myPersonaShare1
  
    !var.update $myPersonaShare1 {
      value = $myPersonaShare1.myDocument
    }
  
    !var.update $myDocuments1 {
      value = $myDocuments1|merge:$myPersonaShare1
    }
  
    var $temp {
      value = []
    }
  
    foreach ($myDocuments1) {
      each as $item {
        conditional {
          if ($item.expiryDate|is_empty) {
            var.update $temp {
              value = $temp
                |push:($item|set:"hasExpiry":false)
            }
          }
        
          else {
            var.update $temp {
              value = $temp
                |push:($item|set:"hasExpiry":true)
            }
          }
        }
      }
    }
  
    !conditional {
      if ($myDocuments1|is_empty) {
      }
    
      else {
        !foreach ($myDocuments1) {
          each as $item {
            !conditional {
              if ($item.document == 0) {
                !var.update $temp {
                  value = $temp|push:($item|set:"document":null)
                }
              }
            
              else {
                !var.update $temp {
                  value = $temp|push:$item
                }
              }
            }
          }
        }
      }
    }
  }

  response = $temp
}