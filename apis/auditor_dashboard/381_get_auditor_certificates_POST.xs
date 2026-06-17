query get_auditor_certificates verb=POST {
  api_group = "auditor_dashboard"

  input {
    text id? filters=trim
  }

  stack {
    db.query auditor_certificates {
      where = $db.auditor_certificates.auditor_id == $input.id
      sort = {auditor_certificates.certificate_name: "asc"}
      return = {type: "list"}
    } as $auditor_certificates_1
  }

  response = $auditor_certificates_1
}