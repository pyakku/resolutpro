query uploadDocumentNoExpiry verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
    text documentName? filters=trim
    int? holderContact?
    int? holderCompany?
    timestamp? issueDate?
    file? document?
    text mypersonaClassification? filters=trim
  }

  stack {
    storage.create_attachment {
      value = $input.document
      access = "public"
      filename = ""
    } as $file
  
    db.get documents {
      field_name = "documentName"
      field_value = $input.documentName
    } as $documents1
  
    conditional {
      if ($documents1 != null) {
        db.add myDocuments {
          enforce_hidden_fields = false
          data = {
            created_at             : "now"
            company                : $input.company
            document               : $documents1.id
            nameUA                 : $input.documentName
            issueDate              : $input.issueDate
            holderContact          : $input.holderContact
            active                 : true
            holder_company         : $input.holderCompany
            myPersona              : true
            mypersonaClassification: $input.mypersonaClassification
            file                   : $file
          }
        } as $myDocuments1
      
        var $dName {
          value = $documents1.documentName
        }
      }
    
      else {
        db.add myDocuments {
          enforce_hidden_fields = false
          data = {
            created_at             : "now"
            company                : $input.company
            nameUA                 : $input.documentName
            issueDate              : $input.issueDate
            holderContact          : $input.holderContact
            active                 : true
            holder_company         : $input.holderCompany
            myPersona              : true
            mypersonaClassification: $input.mypersonaClassification
            file                   : $file
          }
        } as $myDocuments1
      
        var $dName {
          value = $input.documentName
        }
      }
    }
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    api.request {
      url = $env.emailBase
        |concat:"myPersonaUploadDocumentEmailToCustomer.php":""
      method = "POST"
      params = {}
        |set:"firstName":$user1.name
        |set:"docName":$dName
        |set:"email":$user1.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = {done: "done"}
}