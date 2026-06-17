// Add certificate_request record
query certificate_request verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "certificate_request"
      override = {
        c_desc              : {hidden: false}
        c_name              : {hidden: false}
        attachment          : {hidden: false}
        created_at          : {hidden: true}
        requested_by        : {hidden: false}
        accepted_certificate: {hidden: false}
        requested_by_company: {hidden: false}
      }
    }
  }

  stack {
    db.add certificate_request {
      enforce_hidden_fields = false
      data = {
        created_at          : "now"
        requested_by        : $input.requested_by
        c_name              : $input.c_name
        c_desc              : $input.c_desc
        attachment          : $input.attachment
        requested_by_company: $input.requested_by_company
      }
    
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.requested_by}
          as    : "requested_by"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.requested_by_company}
        }
      ]
    } as $certificate_request
  
    api.request {
      url = "https://p3audit.com/itracker/mail_request_certificate.php"
      method = "POST"
      params = {}
        |set:"certificate":$input.c_name
        |set:"by":$certificate_request.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    api.request {
      url = "https://p3audit.com/itracker/mail_request_certificate_to_requester.php"
      method = "POST"
      params = {}
        |set:"certificate":$input.c_name
        |set:"to":$certificate_request.requested_by.name
        |set:"email":$certificate_request.requested_by.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  }

  response = $certificate_request
}