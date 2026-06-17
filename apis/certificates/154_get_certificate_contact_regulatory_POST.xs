query get_certificate_contact_regulatory verb=POST {
  api_group = "Certificates"

  input {
    text contact_id? filters=trim
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.holder == $input.contact_id
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "companies_id"
        "certificates_id"
        "holder"
        "issued_date"
        "expiry_date"
        "issued_by"
        "last_test_date"
        "test_auditor"
        "document.path"
        "document.name"
        "document.type"
        "document.size"
        "document.mime"
        "document.meta"
        "document.url"
      ]
    
      addon = [
        {
          name : "certificates_for_required_certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificates_id"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}