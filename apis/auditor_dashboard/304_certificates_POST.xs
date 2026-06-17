query certificates verb=POST {
  api_group = "auditor_dashboard"

  input {
    text company? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company && $db.required_certificates.document != null
      return = {type: "list"}
      addon = [
        {
          name  : "certificates"
          output: ["type"]
          input : {certificates_id: $output.certificates_id}
        }
        {
          name  : "certificates"
          output: [
            "id"
            "created_at"
            "Certificate_Name"
            "Certificate_Desc"
            "details"
            "q1"
            "q2"
            "q3"
            "q4"
            "q5"
            "approved"
            "type"
            "logo.path"
            "logo.name"
            "logo.type"
            "logo.size"
            "logo.mime"
            "logo.meta"
            "logo.url"
          ]
          input : {certificates_id: $output.certificates_id}
          addon : [
            {
              name : "certificate_types"
              input: {certificate_types_id: $output.type}
              as   : "type"
            }
          ]
          as    : "certificate"
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