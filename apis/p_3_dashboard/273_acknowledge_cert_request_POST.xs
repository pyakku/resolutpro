query acknowledge_cert_request verb=POST {
  api_group = "p3dashboard"

  input {
    text request_id? filters=trim
    text cert_name? filters=trim
    text desc? filters=trim
    text details? filters=trim
    file? logo?
  }

  stack {
    storage.create_image {
      value = $input.logo
      access = "public"
      filename = ""
    } as $var_1
  
    db.add certificates {
      enforce_hidden_fields = false
      data = {
        created_at      : "now"
        Certificate_Name: $input.cert_name
        Certificate_Desc: $input.desc
        details         : $input.details
        approved        : true
        logo            : $var_1
      }
    } as $certificates_1
  
    db.edit certificate_request {
      field_name = "id"
      field_value = $input.request_id
      enforce_hidden_fields = false
      data = {accepted_certificate: $certificates_1.id}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.requested_by_company}
        }
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.requested_by}
        }
      ]
    } as $certificate_request_2
  
    db.query certificate_request {
      where = $db.certificate_request.accepted_certificate == 0
      sort = {certificate_request.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.requested_by_company}
        }
      ]
    } as $certificate_request_1
  
    api.request {
      url = "https://p3audit.com/itracker/mail_request_certificate_accepted.php"
      method = "POST"
      params = {}
        |set:"to":$certificate_request_2.name
        |set:"certificate":$certificate_request_2.c_name
        |set:"email":$certificate_request_2.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  }

  response = $certificate_request_1
}