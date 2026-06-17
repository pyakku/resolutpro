// Query all certificates records
query certificates verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.approved == true
      sort = {certificates.Certificate_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "certificate_types"
          input: {certificate_types_id: $output.type}
          as   : "type"
        }
      ]
    } as $certificates
  }

  response = $certificates
}