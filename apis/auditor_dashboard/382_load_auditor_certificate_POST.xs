query load_auditor_certificate verb=POST {
  api_group = "auditor_dashboard"

  input {
    dblink {
      table = "auditor_certificates"
      override = {
        file            : {hidden: true}
        expiry          : {hidden: false}
        issued          : {hidden: false}
        issuer          : {hidden: false}
        auditor_id      : {hidden: false}
        created_at      : {hidden: true}
        p3_validated    : {hidden: true}
        validation_date : {hidden: true}
        certificate_name: {hidden: false}
      }
    }
  
    file? cert?
  }

  stack {
    storage.create_attachment {
      value = $input.cert
      access = "public"
      filename = ""
    } as $var_1
  
    db.add auditor_certificates {
      enforce_hidden_fields = false
      data = {
        created_at      : "now"
        auditor_id      : $input.auditor_id
        certificate_name: $input.certificate_name
        issued          : $input.issued
        expiry          : $input.expiry
        issuer          : $input.issuer
        file            : $var_1
      }
    } as $auditor_certificates_2
  
    db.query auditor_certificates {
      where = $db.auditor_certificates.auditor_id == $input.auditor_id
      sort = {auditor_certificates.certificate_name: "asc"}
      return = {type: "list"}
    } as $auditor_certificates_1
  }

  response = $auditor_certificates_1
}