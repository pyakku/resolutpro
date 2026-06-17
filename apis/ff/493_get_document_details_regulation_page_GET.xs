query getDocumentDetailsRegulationPage verb=GET {
  api_group = "ff"
  auth = "user"

  input {
  }

  stack {
    db.query documents {
      where = $db.documents.show == true
      sort = {documents.documentName: "asc"}
      return = {type: "list"}
      addon = [
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
    } as $documents1
  }

  response = $documents1
}