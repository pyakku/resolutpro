query autoLogin verb=POST {
  api_group = "Auditor FF"

  input {
    uuid? wind?
  }

  stack {
    db.get audit {
      field_name = "auditIDP3"
      field_value = $input.wind
      addon = [
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
      ]
    } as $audit1
  
    security.create_auth_token {
      table = "auditor"
      extras = {}
      expiration = 0
      id = $audit1.auditor_id
    } as $authToken
  }

  response = {
    companyID  : $audit1.companies_id
    companyName: $audit1.Company_Name
    auditID    : $audit1.id
    authToken  : $authToken
  }
}