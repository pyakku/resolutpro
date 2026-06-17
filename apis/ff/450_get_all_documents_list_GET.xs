query getAllDocumentsList verb=GET {
  api_group = "ff"

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