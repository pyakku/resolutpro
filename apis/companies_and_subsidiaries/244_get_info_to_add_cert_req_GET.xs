query get_info_to_add_cert_req verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.approved == true
      return = {type: "list"}
    } as $certificates_1
  
    db.query countries {
      return = {type: "list"}
    } as $countries_1
  
    db.query functions {
      return = {type: "list"}
    } as $functions_1
  }

  response = {
    certificates: $certificates_1
    countries   : $countries_1
    functions   : $functions_1
  }
}