// Get All Documents of the current User
query getRequiredDocumentsForAudit verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    db.get audit_types {
      field_name = "id"
      field_value = $audit1.audit_types_id
    } as $audit_types1
  
    conditional {
      if ($audit_types1.documentsRequired|is_empty) {
        return {
          value = []
        }
      }
    
      else {
        !db.query myDocuments {
          where = $db.myDocuments.id in $audit1.sharedDocuments
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
      
        db.query documents {
          where = $db.documents.id in $audit_types1.documentsRequired
          return = {type: "list"}
        } as $documents1
      
        var $x1 {
          value = []
        }
      
        foreach ($documents1) {
          each as $item {
            db.query myDocuments {
              where = $db.myDocuments.company == $audit1.companies_id && $db.myDocuments.document == $item.id && $db.myDocuments.validated == true && $db.myDocuments.active == true && $db.myDocuments.archived == false
              return = {type: "single"}
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
              if ($myDocuments1|is_empty) {
                var.update $x1 {
                  value = $x1
                    |push:($item
                      |set:"has":false
                      |set:"documentDetails":null
                    )
                }
              }
            
              else {
                var.update $x1 {
                  value = $x1
                    |push:($item
                      |set:"has":true
                      |set:"documentDetails":$myDocuments1
                    )
                }
              }
            }
          }
        }
      }
    }
  }

  response = $x1
}