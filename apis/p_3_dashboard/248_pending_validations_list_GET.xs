query pending_validations_list verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.active == true && $db.required_certificates.p3_audited == false && $db.required_certificates.document != null && $db.required_certificates.sla_extender == 0 && $db.required_certificates.rejected != true
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
        {name: "user", input: {user_id: $output.user}, as: "user"}
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}