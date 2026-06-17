query edit_certificate verb=POST {
  api_group = "Certificates"

  input {
    text id? filters=trim
    text issue? filters=trim
    text expiry? filters=trim
    int holder?
    text issued_by? filters=trim
    text last_test_date? filters=trim
    text test_auditor? filters=trim
  }

  stack {
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        holder        : $input.holder
        issued_date   : $input.issue
        expiry_date   : $input.expiry
        issued_by     : $input.issued_by
        last_test_date: $input.last_test_date
        test_auditor  : $input.test_auditor
      }
    
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "user"
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
    } as $required_certificates_1
  
    api.request {
      url = "https://p3audit.com/itracker/upload_cert_email_p3.php"
      method = "POST"
      params = {}
        |set:"c_name":$required_certificates_1.certificates_id.Certificate_Name
        |set:"company":$required_certificates_1.companies_id.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    api.request {
      url = "https://p3audit.com/itracker/upload_cert_mail_customer.php"
      method = "POST"
      params = {}
        |set:"c_name":$required_certificates_1.certificates_id.Certificate_Name
        |set:"contact":$required_certificates_1.companies_id.user.name
        |set:"u_name":$required_certificates_1.companies_id.user.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  }

  response = $required_certificates_1
}