query shareDocument verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int myDocument?
    int company?
    text role? filters=trim
    bool employer?
  }

  stack {
    db.query myPersonaShare {
      where = $db.myPersonaShare.myDocument == $input.myDocument && $db.myPersonaShare.company == $input.company && $db.myPersonaShare.active == true
      return = {type: "list"}
    } as $myPersonaShare1
  
    conditional {
      if (($myPersonaShare1|is_empty) == false) {
      }
    
      else {
        db.get myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        } as $myDocuments1
      
        db.get user {
          field_name = "id"
          field_value = $auth.id
        } as $user1
      
        db.get companies {
          field_name = "id"
          field_value = $input.company
        } as $companies1
      
        db.get subscriptions {
          field_name = "company"
          field_value = $input.company
        } as $subscriptions1
      
        db.get user {
          field_name = "id"
          field_value = $subscriptions1.user_id
        } as $contact
      
        db.get contacts {
          field_name = "email"
          field_value = $user1.email
        } as $contactsDetails
      
        db.query contact_relationship {
          where = $db.contact_relationship.contact == $contactsDetails.id && $db.contact_relationship.company == $input.company
          return = {type: "list"}
        } as $contact_relationship1
      
        conditional {
          if ($contact_relationship1|is_empty) {
            db.add contact_relationship {
              enforce_hidden_fields = false
              data = {
                created_at: "now"
                contact   : $contactsDetails.id
                company   : $input.company
                role      : $input.role
                approved  : false
                mypersona : true
                employer  : $input.employer
              }
            } as $contact_relationship2
          }
        }
      
        db.add myPersonaShare {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            myDocument: $input.myDocument
            company   : $input.company
            active    : true
          }
        } as $myPersonaShare2
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaShareDocument.php":""
          method = "POST"
          params = {}
            |set:"documentName":$myDocuments1.nameUA
            |set:"companyName":$companies1.Company_Name
            |set:"email":$user1.email
            |set:"firstName":$user1.name
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaShareDocumentToReciepent.php":""
          method = "POST"
          params = {}
            |set:"documentName":$myDocuments1.nameUA
            |set:"companyName":$companies1.Company_Name
            |set:"email":$user1.email
            |set:"firstName":$user1.name
            |set:"contactName":$contact.name
            |set:"contactEmail":$contact.email
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      }
    }
  }

  response = $myPersonaShare1
}