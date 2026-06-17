query all_certificates verb=POST {
  api_group = "Reports_Page"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.document != null
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          addon: [
            {
              name : "certificate_types"
              input: {certificate_types_id: $output.type}
              as   : "type"
            }
          ]
          as   : "certificates_id"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}