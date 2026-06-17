query getAdditionalDocumentsAudit verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.$this}
          addon: [
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
          ]
          as   : "sharedDocuments"
        }
      ]
    } as $audit1
  
    conditional {
      if ($audit1.sharedDocuments|is_empty) {
        return {
          value = []
        }
      }
    
      else {
        return {
          value = $audit1.sharedDocuments
        }
      }
    }
  }

  response = $audit1
}