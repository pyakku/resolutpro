// Get All Documents of the current User
query getMyDocuments verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int company?
    int documentClassification?
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
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.company == $input.company
          return = {type: "list"}
        } as $myPersonaShare1
      
        conditional {
          if (($myPersonaShare1|is_empty) == false) {
            var.update $myPersonaShare1 {
              value = $myPersonaShare1.myDocument
            }
          
            db.query myDocuments {
              where = $db.myDocuments.id in $myPersonaShare1
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
          
            conditional {
              if (($myDocuments2|is_empty) == false) {
                var.update $myDocuments1 {
                  value = $myDocuments1|merge:$myDocuments2
                }
              }
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
  }

  response = $myDocuments1
}