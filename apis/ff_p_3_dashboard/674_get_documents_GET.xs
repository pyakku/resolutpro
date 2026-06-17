query getDocuments verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query documents {
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