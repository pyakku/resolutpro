query documentDownloaded verb=POST {
  api_group = "myPersonaFF"

  input {
    text controller? filters=trim
    int myDocument?
  }

  stack {
    db.get share_audits {
      field_name = "controller"
      field_value = $input.controller
    } as $share_audits1
  
    conditional {
      if ($share_audits1.myPersona) {
        db.get myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        } as $myDocuments1
      
        db.get companies {
          field_name = "id"
          field_value = $share_audits1.company
        } as $companies1
      
        db.get user {
          field_name = "id"
          field_value = $companies1.created_by_user
        } as $user1
      
        var $userEmail {
          value = $user1.email
        }
      
        var $userName {
          value = $user1.name
        }
      
        var $recieverName {
          value = $share_audits1.f_name
            |concat:(" "|concat:$share_audits1.l_name:""):""
        }
      
        var $recieverEmail {
          value = $share_audits1.email
        }
      
        var $currentTime {
          value = now|format_timestamp:"r":"UTC"
        }
      
        var $companyName {
          value = $companies1.Company_Name
        }
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaDocumentDownloaded.php":""
          method = "POST"
          params = {}
            |set:"owner_fname":$userName
            |set:"owner_email":$userEmail
            |set:"document":$myDocuments1.nameUA
            |set:"recipient_name":$recieverName
            |set:"recipient_email":$recieverEmail
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      }
    
      else {
        db.get myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        } as $myDocuments1
      
        db.get companies {
          field_name = "id"
          field_value = $share_audits1.company
        } as $companies1
      
        db.get user {
          field_name = "id"
          field_value = $companies1.created_by_user
        } as $user1
      
        var $userEmail {
          value = $user1.email
        }
      
        var $userName {
          value = $user1.name
        }
      
        var $recieverName {
          value = $share_audits1.f_name
            |concat:(" "|concat:$share_audits1.l_name:""):""
        }
      
        var $recieverEmail {
          value = $share_audits1.email
        }
      
        var $currentTime {
          value = now|format_timestamp:"r":"UTC"
        }
      
        var $companyName {
          value = $companies1.Company_Name
        }
      
        api.request {
          url = $env.emailBase
            |concat:"p3DocumentDownloaded.php":""
          method = "POST"
          params = {}
            |set:"owner_fname":$userName
            |set:"owner_email":$userEmail
            |set:"document":$myDocuments1.nameUA
            |set:"recipient_name":$recieverName
            |set:"recipient_email":$recieverEmail
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      }
    }
  }

  response = $share_audits1
}