query new_certificate_page verb=POST {
  api_group = "Certificates"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.required_for_compliance == true && $db.required_certificates.sla_extender == 0
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $required_certificates
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.required_for_compliance == false && $db.required_certificates.sla_extender == 0
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $other_certificates
  
    db.query certificates {
      where = $db.certificates.approved == true
      return = {type: "list"}
    } as $all_certificates
  
    db.query companies {
      where = $db.companies.id == $input.company_id
      return = {type: "list"}
      addon = [
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions"
        }
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions_inactive"
        }
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          addon: [
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "created_by_user"
        }
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_code"
        }
        {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
      ]
    } as $company_details
  }

  response = {
    required_certificates: $required_certificates
    other_certificates   : $other_certificates
    all_certificates     : $all_certificates
    company_details      : $company_details
  }
}