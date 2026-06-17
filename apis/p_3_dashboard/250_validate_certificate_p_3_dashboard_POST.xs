query validate_certificate_p3_dashboard verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
    text user? filters=trim
  }

  stack {
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        p3_audited  : true
        validated_on: now
        rejected    : false
        user        : $input.user|to_int
      }
    
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "companies_id"
        }
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $required_certificates_2
  
    db.query required_certificates {
      where = $db.required_certificates.active == true && $db.required_certificates.p3_audited == false && $db.required_certificates.document != null && $db.required_certificates.sla_extender == 0
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
        {
          name : "companies"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder"
        }
      ]
    } as $required_certificates_1
  
    api.request {
      url = "https://p3audit.com/itracker/validate_cert_mail.php"
      method = "POST"
      params = {}
        |set:"contact":$required_certificates_2.companies_id.created_by_user.name
        |set:"u_name":$required_certificates_2.companies_id.created_by_user.email
        |set:"c_name":$required_certificates_2.certificates_id.Certificate_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = $required_certificates_1
}