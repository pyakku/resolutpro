// Get All Documents of the current User
query getSharedDocumentsForAudit verb=POST {
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
  
    conditional {
      if ($audit1.sharedDocuments|is_empty) {
        return {
          value = []
        }
      }
    
      else {
        db.query myDocuments {
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
      }
    }
  }

  response = $myDocuments1
}