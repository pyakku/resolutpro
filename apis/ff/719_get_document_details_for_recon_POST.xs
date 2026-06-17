query getDocumentDetailsForRecon verb=POST {
  api_group = "ff"

  input {
    int id?
  }

  stack {
    db.get myDocuments {
      field_name = "id"
      field_value = $input.id
    } as $myDocuments1
  }

  response = $myDocuments1
}