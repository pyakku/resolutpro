query delete_cert_type verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
  }

  stack {
    db.del certificate_types {
      field_name = "id"
      field_value = $input.id
    }
  
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