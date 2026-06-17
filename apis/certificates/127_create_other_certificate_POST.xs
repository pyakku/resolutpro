query create_other_certificate verb=POST {
  api_group = "Certificates"

  input {
    file document?
    text details? filters=trim
    text expiry? filters=trim
    int company_id?
    text auth_body? filters=trim
  }

  stack {
    storage.create_attachment {
      value = $input.document
      access = "public"
    } as $document
  
    db.add other_certificates {
      enforce_hidden_fields = false
      data = {
        created_at    : "now"
        company_id    : $input.company_id
        details       : $input.details
        auth_body     : $input.auth_body
        holder        : "0"
        issued_date   : ""
        last_test_date: ""
        test_auditor  : ""
        expiry_date   : ""
        document      : $document
      }
    } as $other_certificates_1
  }

  response = $other_certificates_1
}