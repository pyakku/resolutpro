query add_cert_type verb=POST {
  api_group = "p3dashboard"

  input {
    text type? filters=trim
  }

  stack {
    db.add certificate_types {
      enforce_hidden_fields = false
      data = {created_at: "now", type: $input.type}
    } as $certificate_types_2
  
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