query certificates_for_policy verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.active == true
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $required_certificates_1
  
    db.query other_certificates {
      where = $db.other_certificates.company_id == $input.company_id
      return = {type: "list"}
    } as $other_certificates_1
  }

  response = {
    other   : $other_certificates_1
    required: $required_certificates_1
  }
}