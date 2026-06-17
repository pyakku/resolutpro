query certificate_types_page_load verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.approved == true
      return = {type: "list"}
    } as $certificates_1
  
    db.query certificate_types {
      sort = {certificate_types.type: "asc"}
      return = {type: "list"}
    } as $certificate_types_1
  }

  response = {
    certificates: $certificates_1
    types       : $certificate_types_1
  }
}