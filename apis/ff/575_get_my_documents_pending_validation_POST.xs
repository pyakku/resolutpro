// Get All Documents of the current User
query getMyDocumentsPendingValidation verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
    int documentClassification?
  }

  stack {
    conditional {
      if ($input.documentClassification == 0) {
        db.query myDocuments {
          where = $db.myDocuments.company == $input.company && $db.myDocuments.active == true && $db.myDocuments.archived == false && $db.myDocuments.validated == false && $db.myDocuments.rejected == false
          sort = {
            myDocuments.expiryDate: "asc"
            myDocuments.created_at: "desc"
          }
        
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
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.company == $input.company && $db.myPersonaShare.active == true && $db.myPersonaShare.approvedByReciepent == true
          return = {type: "list"}
        } as $myPersonaShare1
      
        conditional {
          if (($myPersonaShare1|is_empty) == false) {
            var.update $myPersonaShare1 {
              value = $myPersonaShare1.myDocument
            }
          
            db.query myDocuments {
              where = $db.myDocuments.id in $myPersonaShare1 && $db.myDocuments.active == true && $db.myDocuments.archived == false && $db.myDocuments.validated == false && $db.myDocuments.rejected == false
              sort = {
                myDocuments.expiryDate: "asc"
                myDocuments.created_at: "desc"
              }
            
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
            } as $myDocuments2
          
            var.update $myDocuments1 {
              value = $myDocuments1|merge:$myDocuments2
            }
          }
        }
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
          where = $db.myDocuments.company == $input.company && $db.myDocuments.active == true && $db.myDocuments.document in $documents1 && $db.myDocuments.archived == false && $db.myDocuments.validated == false && $db.myDocuments.rejected == false
          sort = {
            myDocuments.expiryDate: "asc"
            myDocuments.created_at: "desc"
          }
        
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
  }

  response = $myDocuments1
}