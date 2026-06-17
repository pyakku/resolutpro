query shareDocEmail verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
    int document?
    text email? filters=trim
    text fname? filters=trim
    text lname? filters=trim
    bool download?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get myDocuments {
      field_name = "id"
      field_value = $input.document
    } as $myDocuments1
  
    security.create_secret_key {
      bits = 256
      format = "base64"
    } as $crypto1
  
    db.query share_audits {
      where = $input.document in $db.share_audits.documents && $db.share_audits.email == ($input.email|to_lower) && $db.share_audits.myPersona == true && $db.share_audits.company == $db.share_audits.company
      return = {type: "exists"}
    } as $exists
  
    conditional {
      if ($exists) {
        db.query share_audits {
          where = $input.document in $db.share_audits.documents && $db.share_audits.email == $input.email && $db.share_audits.myPersona == true && $db.share_audits.company == $db.share_audits.company
          return = {type: "single"}
        } as $share_audits1
      
        db.edit share_audits {
          field_name = "id"
          field_value = $share_audits1.id
          enforce_hidden_fields = false
          data = {
            company : $input.company
            f_name  : $input.fname
            l_name  : $input.lname
            download: $input.download
          }
        } as $share_audits1
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaShareDocumentByEmail.php":""
          method = "POST"
          params = {}
            |set:"recipient_fname":$input.fname
            |set:"sharer_fname":$user1.name
            |set:"sharer_lname":$user1.l_name
            |set:"email":$input.email
            |set:"link":("https://documentsharing.p3audit.com/documentShare?sessionID="
              |concat:$share_audits1.controller:""
            )
            |set:"document":$myDocuments1.nameUA
            |set:"date":"empty"
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.myDocument == $input.document && $db.myPersonaShare.shareLink == $share_audits1.id
          return = {type: "exists"}
        } as $myPersonaShare2
      
        conditional {
          if ($myPersonaShare2) {
            db.query myPersonaShare {
              where = $db.myPersonaShare.myDocument == $input.document && $db.myPersonaShare.shareLink == $share_audits1.id
              return = {type: "single"}
            } as $myPersonaShare2
          
            db.edit myPersonaShare {
              field_name = "id"
              field_value = $myPersonaShare2.id
              enforce_hidden_fields = false
              data = {
                company     : $input.company
                active      : true
                name        : $input.fname
                lName       : $input.lname
                shareByEmail: true
              }
            } as $myPersonaShare1
          }
        
          else {
            db.add myPersonaShare {
              enforce_hidden_fields = false
              data = {
                created_at         : "now"
                myDocument         : $input.document
                active             : true
                approvedByReciepent: true
                name               : $input.fname
                email              : $input.email|to_lower
                lName              : $input.lname
                shareLink          : $share_audits1.id
                shareByEmail       : true
              }
            } as $myPersonaShare1
          }
        }
      }
    
      else {
        db.add share_audits {
          enforce_hidden_fields = false
          data = {
            created_at : "now"
            company    : $input.company
            f_name     : $input.fname
            l_name     : $input.lname
            email      : $input.email|to_lower
            controller : $crypto1
            documents  : $input.document|safe_array
            sendHistory: now
            myPersona  : true
            download   : $input.download
          }
        } as $share_audits1
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaShareDocumentByEmail.php":""
          method = "POST"
          params = {}
            |set:"recipient_fname":$input.fname
            |set:"sharer_fname":$user1.name
            |set:"sharer_lname":$user1.l_name
            |set:"email":$input.email
            |set:"link":("https://documentsharing.p3audit.com/documentShare?sessionID="
              |concat:$share_audits1.controller:""
            )
            |set:"document":$myDocuments1.nameUA
            |set:"date":"empty"
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      
        db.add myPersonaShare {
          enforce_hidden_fields = false
          data = {
            created_at         : "now"
            myDocument         : $input.document
            active             : true
            approvedByReciepent: true
            name               : $input.fname
            email              : $input.email|to_lower
            lName              : $input.lname
            shareLink          : $share_audits1.id
            shareByEmail       : true
          }
        } as $myPersonaShare1
      }
    }
  
    api.request {
      url = "https://itrackersignup.p3audit.com/emailAPIs/myPersonaShareDocEmailToSender.php"
      method = "POST"
      params = {}
        |set:"documentName":$myDocuments1.nameUA
        |set:"reciever":($input.fname|concat:$input.lname:" ")
        |set:"recieverEmail":$input.email
        |set:"email":$user1.email
        |set:"firstName":$user1.name
      headers = []
        |push:"Content-Type: application/json"
    } as $api2
  }

  response = $share_audits1
}