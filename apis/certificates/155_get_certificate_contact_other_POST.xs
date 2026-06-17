query get_certificate_contact_other verb=POST {
  api_group = "Certificates"

  input {
    text contact_id? filters=trim
  }

  stack {
    db.query other_certificates {
      where = $db.other_certificates.holder == $input.contact_id
      return = {type: "list"}
    } as $other_certificates_1
  }

  response = $other_certificates_1
}