query load_certificate_list verb=POST {
  api_group = "certificates_new"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.type != 27 && $db.certificates.approved == true
      return = {type: "list"}
      addon = [
        {
          name : "certificate_types"
          input: {certificate_types_id: $output.type}
          as   : "type"
        }
      ]
    } as $certificates_1
  }

  response = $certificates_1
}