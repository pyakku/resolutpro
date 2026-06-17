query stopSharing verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int shareID?
  }

  stack {
    db.edit myPersonaShare {
      field_name = "id"
      field_value = $input.shareID
      enforce_hidden_fields = false
      data = {stoppedOn: now, active: false}
    } as $myPersonaShare1
  
    conditional {
      if ($myPersonaShare1.shareLink|is_empty) {
      }
    
      else {
        db.edit share_audits {
          field_name = "id"
          field_value = $myPersonaShare1.shareLink
          enforce_hidden_fields = false
          data = {valid: now}
        } as $share_audits1
      
        db.get myDocuments {
          field_name = "id"
          field_value = $myPersonaShare1.myDocument
        } as $myDocuments1
      
        db.get user {
          field_name = "id"
          field_value = $auth.id
        } as $user1
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaShareStopped.php":""
          method = "POST"
          params = {}
            |set:"documentName":$myDocuments1.nameUA
            |set:"contactName":$myPersonaShare1.name
            |set:"contactEmail":$myPersonaShare1.email
            |set:"email":$user1.email
            |set:"name":($user1.name|concat:$user1.l_name:" ")
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaStopSharingToOwner.php":""
          method = "POST"
          params = {}
            |set:"documentName":$myDocuments1.nameUA
            |set:"reciever":($myPersonaShare1.name
              |concat:$myPersonaShare1.lName:" "
            )
            |set:"recieverEmail":$myPersonaShare1.email
            |set:"email":$user1.email
            |set:"firstName":$user1.name
          headers = []
            |push:"Content-Type: application/json"
        } as $api2
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api2}
        } as $email_log1
      }
    }
  }

  response = $myPersonaShare1
}