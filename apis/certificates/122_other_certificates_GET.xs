// Query all other_certificates records
query other_certificates verb=GET {
  api_group = "Certificates"

  input {
  }

  stack {
    db.query other_certificates {
      return = {type: "list"}
    } as $other_certificates
  }

  response = $other_certificates
}