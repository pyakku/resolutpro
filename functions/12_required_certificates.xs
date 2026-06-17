function required_certificates {
  input {
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.required_for_compliance == true && $db.required_certificates.active == true
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "companies_id"
        "certificates_id"
        "active"
        "holder"
        "issued_date"
        "expiry_date"
        "issued_by"
        "last_test_date"
        "test_auditor"
        "required_for_compliance"
        "self_attested"
        "remote_validation"
        "p3_audited"
        "sla_extender"
        "document"
      ]
    
      addon = [
        {
          name  : "company_name_for_certifications"
          output: [
            "id"
            "company_reg"
            "created_by"
            "Company_Name"
            "industry"
            "country"
          ]
          input : {companies_id: $output.companies_id}
          as    : "_companies"
        }
        {
          name  : "certificates_for_required_certificates"
          output: [
            "id"
            "created_at"
            "Certificate_Name"
            "Certificate_Desc"
            "approved"
          ]
          input : {certificates_id: $output.certificates_id}
          as    : "certificate"
        }
      ]
    } as $required_certificates
  }

  response = $required_certificates
}