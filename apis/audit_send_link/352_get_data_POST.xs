query get_data verb=POST {
  api_group = "Audit_Send Link"

  input {
    text company? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company && $db.required_certificates.active == true && $db.required_certificates.document != null
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $required_certificates_1
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "policies"
          input: {policies_id: $output.policies_id}
          as   : "policies_id"
        }
      ]
    } as $my_policies_1
  }

  response = {
    certificates: $required_certificates_1
    policies    : $my_policies_1
  }
}