query getDocumentsOfClassification verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int classification?
  }

  stack {
    db.query documents {
      where = $db.documents.documentClassification == $input.classification
      sort = {documents.documentName: "asc"}
      return = {type: "list"}
      addon = [
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