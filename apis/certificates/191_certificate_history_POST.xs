query certificate_history verb=POST {
  api_group = "Certificates"

  input {
    text certificate_id? filters=trim
    text company_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.certificates_id == $input.certificate_id && $db.required_certificates.companies_id == $input.company_id
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "companies_id"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder"
        }
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}