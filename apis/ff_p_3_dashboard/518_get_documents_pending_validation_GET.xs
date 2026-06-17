query getDocumentsPendingValidation verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.document == null || $db.myDocuments.document == 0 || ($db.myDocuments.validated == false && $db.myDocuments.rejected == false)
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
  
    db.query myPersonaShare {
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
  
    var.update $myPersonaShare1 {
      value = $myPersonaShare1.myDocument
    }
  
    array.filter ($myPersonaShare1) if ($this.validated == false && $this.rejected == false) as $myPersonaShare1
    var.update $myDocuments1 {
      value = $myDocuments1|merge:$myPersonaShare1
    }
  
    var $temp {
      value = []
    }
  
    conditional {
      if ($myDocuments1|is_empty) {
      }
    
      else {
        foreach ($myDocuments1) {
          each as $item {
            conditional {
              if ($item.document == 0) {
                conditional {
                  if ($item.expiryDate|is_empty) {
                    var.update $temp {
                      value = $temp
                        |push:($item
                          |set:"document":null
                          |set:"hasExpiry":false
                        )
                    }
                  }
                
                  else {
                    var.update $temp {
                      value = $temp
                        |push:($item
                          |set:"document":null
                          |set:"hasExpiry":true
                        )
                    }
                  }
                }
              }
            
              else {
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
          }
        }
      }
    }
  }

  response = $temp
}