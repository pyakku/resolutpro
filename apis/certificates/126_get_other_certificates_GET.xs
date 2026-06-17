query get_other_certificates verb=GET {
  api_group = "Certificates"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query other_certificates {
      where = $db.other_certificates.company_id == $input.company_id
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "company_id"
        "details"
        "auth_body"
        "holder"
        "issued_date"
        "last_test_date"
        "test_auditor"
        "expiry_date"
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
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder"
        }
      ]
    } as $other_certificates_1
  }

  response = $other_certificates_1
}