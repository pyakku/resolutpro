query getDocumentList verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query documents {
      sort = {documents.documentName: "asc"}
      return = {type: "list"}
    } as $documents1
  }

  response = $documents1
}