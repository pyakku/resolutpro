query get_sia_score verb=POST {
  api_group = "sia"

  input {
    text company_id? filters=trim
  }

  stack {
    var $list {
      value = []
        |push:108
        |push:109
        |push:98
        |push:10
        |push:105
        |push:107
        |push:106
    }
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.certificates_id in $list && $db.required_certificates.document != null
      return = {type: "list"}
    } as $required_certificates_1
  }

  response = $required_certificates_1
}