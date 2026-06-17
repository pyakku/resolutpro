query get_all_pending_cert_requests_2 verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.approved == false
      return = {type: "list"}
      output = ["id"]
    } as $certificates_1
  
    var.update $certificates_1 {
      value = $certificates_1.id
    }
  
    db.query required_certificates {
      where = $db.required_certificates.certificates_id in $certificates_1
      return = {type: "list"}
      addon = [
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "companies_id"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}