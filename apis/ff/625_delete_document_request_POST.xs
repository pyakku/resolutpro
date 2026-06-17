query deleteDocumentRequest verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int myDocument?
  }

  stack {
    db.edit myDocuments {
      field_name = "id"
      field_value = $input.myDocument
      enforce_hidden_fields = false
      data = {markedForDeletion: true}
    } as $myDocuments1
  
    db.get companies {
      field_name = "id"
      field_value = $myDocuments1.company
    } as $companies1
  
    db.get user {
      field_name = "id"
      field_value = $companies1.created_by_user
    } as $user1
  
    api.request {
      url = $env.emailBase
        |concat:"deleteRequestToClientAndP3.php":""
      method = "POST"
      params = {}
        |set:"company":$companies1.Company_Name
        |set:"contact_email":$user1.email
        |set:"document":$myDocuments1.nameUA
        |set:"primary_user":$user1.name
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $myDocuments1
}