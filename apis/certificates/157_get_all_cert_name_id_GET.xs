query get_all_cert_name_id verb=GET {
  api_group = "Certificates"

  input {
  }

  stack {
    db.query certificates {
      where = $db.certificates.approved == true
      return = {type: "list"}
      output = [
        "id"
        "Certificate_Name"
        "logo.path"
        "logo.name"
        "logo.type"
        "logo.size"
        "logo.mime"
        "logo.meta"
        "logo.url"
      ]
    } as $certificates_1
  }

  response = $certificates_1
}