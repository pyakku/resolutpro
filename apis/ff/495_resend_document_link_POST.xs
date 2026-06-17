query resendDocumentLink verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int id?
  }

  stack {
    db.get share_audits {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
      ]
    } as $share_audits1
  
    var $f_name {
      value = $share_audits1.f_name
    }
  
    var $documents {
      value = $share_audits1.documents|count
    }
  
    var $l_name {
      value = $share_audits1.l_name
    }
  
    var $email {
      value = $share_audits1.email
    }
  
    var $controller {
      value = $share_audits1.controller
    }
  
    conditional {
      if ($share_audits1.valid == null) {
        api.request {
          url = $env.emailBase|concat:"senddocuments.php":""
          method = "POST"
          params = {}
            |set:"name":$f_name
            |set:"companyname":$share_audits1.Company_Name
            |set:"email":$email
            |set:"date":"empty"
            |set:"link":("https://documentsharing.p3audit.com/documentShare?sessionID="|concat:$controller:"")
            |set:"count":$documents
          headers = []
            |push:"Content-Type: application/json"
          timeout = 25
          verify_host = false
          verify_peer = false
        } as $api_1
      }
    
      else {
        api.request {
          url = $env.emailBase|concat:"senddocuments.php":""
          method = "POST"
          params = {}
            |set:"name":$f_name
            |set:"companyname":$share_audits1.Company_Name
            |set:"email":$email
            |set:"date":($share_audits1.valid|format_timestamp:"r":"UTC")
            |set:"link":("https://documentsharing.p3audit.com/documentShare?sessionID="|concat:$controller:"")
            |set:"count":$documents
          headers = []
            |push:"Content-Type: application/json"
          timeout = 25
          verify_host = false
          verify_peer = false
        } as $api_1
      }
    }
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  
    db.edit share_audits {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {sendHistory: $share_audits1.sendHistory|unshift:now}
    } as $share_audits2
  }

  response = $share_audits1
}