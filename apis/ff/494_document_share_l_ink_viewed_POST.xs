query documentShareLInkViewed verb=POST {
  api_group = "ff"

  input {
    text controller? filters=trim
  }

  stack {
    db.get share_audits {
      field_name = "controller"
      field_value = $input.controller
    } as $share_audits1
  
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
  
    conditional {
      if ($share_audits1.viewed) {
      }
    
      else {
        db.edit share_audits {
          field_name = "controller"
          field_value = $input.controller
          enforce_hidden_fields = false
          data = {viewed: true}
        } as $share_audits2
      
        api.request {
          url = $env.emailBase
            |concat:"sendNotificationDocumentsViewed.php":""
          method = "POST"
          params = {}
            |set:"ownerEmail":$userEmail
            |set:"ownerName":$userName
            |set:"viewerName":$recieverName
            |set:"viewerEmail":$recieverEmail
            |set:"time":$currentTime
            |set:"company":$companyName
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