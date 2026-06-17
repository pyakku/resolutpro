query getDocumentsOfType verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int type?
  }

  stack {
    db.query documents {
      where = $db.documents.documentType == $input.type
      sort = {documents.documentName: "asc"}
      return = {type: "list"}
      addon = [
        {
          name  : "documentClassification"
          output: ["classification"]
          input : {documentClassification_id: $output.documentClassification}
        }
      ]
    } as $documents1
  }

  response = $documents1
}