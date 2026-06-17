query send_link verb=POST {
  api_group = "Audit_Send Link"
  auth = "user"

  input {
    text f_name? filters=trim
    text l_name? filters=trim
    text email? filters=trim
    timestamp? date?
    int[] documents?
    int company?
    bool downloadable?
  }

  stack {
    security.create_secret_key {
      bits = 256
      format = "base64"
    } as $crypto_1
  
    db.add share_audits {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        company    : $input.company
        f_name     : $input.f_name
        l_name     : $input.l_name
        email      : $input.email
        controller : $crypto_1
        valid      : $input.date
        documents  : $input.documents
        sendHistory: now
        myPersona  : false
        download   : $input.downloadable
      }
    
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
      ]
    } as $share_audits_1
  
    conditional {
      if ($input.date == null) {
        api.request {
          url = $env.emailBase|concat:"senddocuments.php":""
          method = "POST"
          params = {}
            |set:"name":$input.f_name
            |set:"companyname":$share_audits_1.company.Company_Name
            |set:"email":$input.email
            |set:"date":"empty"
            |set:"link":("https://documentsharing.p3audit.com/documentShare?sessionID="
              |concat:$share_audits_1.controller:""
            )
            |set:"count":($input.documents|count)
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
            |set:"name":$input.f_name
            |set:"companyname":$share_audits_1.company.Company_Name
            |set:"email":$input.email
            |set:"date":($input.date|format_timestamp:"r":"UTC")
            |set:"link":("https://documentsharing.p3audit.com/documentShare?sessionID="
              |concat:$share_audits_1.controller:""
            )
            |set:"count":($input.documents|count)
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
  
    db.add timeline {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        company   : $input.company|to_int
        user      : $auth.id
        desc      : $input.documents|count|concat:" documents shared":""
      }
    } as $timeline1
  }

  response = $share_audits_1
}