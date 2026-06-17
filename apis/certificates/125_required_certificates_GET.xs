query required_certificates verb=GET {
  api_group = "Certificates"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id
      sort = {
        required_certificates.document   : "asc"
        required_certificates.expiry_date: "desc"
      }
    
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
        {
          name : "kpi"
          input: {kpi_id: $output.sla_extender}
          as   : "sla_extender"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}