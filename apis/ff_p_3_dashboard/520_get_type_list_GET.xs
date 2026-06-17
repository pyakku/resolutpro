query getTypeList verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query document_types {
      sort = {document_types.type: "asc"}
      return = {type: "list"}
    } as $document_types1
  }

  response = $document_types1
}