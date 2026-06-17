query get_all_bbeee verb=GET {
  api_group = "BBEEE"

  input {
  }

  stack {
    db.query required_certificates {
      join = {
        bbeee_validation: {
          table: "bbeee_validation"
          type : "left"
          where: $db.required_certificates.id == $db.bbeee_validation.certificate
        }
      }
    
      where = $db.required_certificates.certificates_id == 101 && $db.required_certificates.active == true && $db.required_certificates.document != null
      eval = {level: $db.bbeee_validation.level}
      return = {type: "list"}
      addon = [
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