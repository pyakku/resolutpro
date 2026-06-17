query revoke_validate_certificate_p3_dashboard verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
    text user? filters=trim
  }

  stack {
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {p3_audited: false, user: $input.user|to_int}
    } as $required_certificates_2
  
    db.query required_certificates {
      where = $db.required_certificates.active == true && $db.required_certificates.p3_audited == true && $db.required_certificates.document != null && $db.required_certificates.sla_extender == 0
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
        {
          name : "companies"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
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