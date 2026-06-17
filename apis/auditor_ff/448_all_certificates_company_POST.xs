query all_Certificates_company verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int company?
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company
      return = {type: "list"}
      addon = [
        {
          name  : "certificates"
          output: [
            "Certificate_Name"
            "type"
            "logo.access"
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
              name  : "certificate_types"
              output: ["id", "created_at", "type"]
              input : {certificate_types_id: $output.type}
              as    : "c_type"
            }
          ]
          as    : "certificate"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder_contact"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.holder_company}
          as    : "holder_company"
        }
      ]
    } as $required_certificates1
  }

  response = $required_certificates1
}