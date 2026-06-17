query add_certificate verb=POST {
  api_group = "certificates_new"

  input {
    dblink {
      table = "required_certificates"
      override = {
        active                 : {hidden: true}
        holder                 : {hidden: false}
        document               : {hidden: true}
        rejected               : {hidden: true}
        issued_by              : {hidden: false}
        created_at             : {hidden: true}
        p3_audited             : {hidden: true}
        expiry_date            : {hidden: false}
        issued_date            : {hidden: false}
        rejected_on            : {hidden: true}
        companies_id           : {hidden: false}
        product_name           : {hidden: true}
        sla_extender           : {hidden: true}
        test_auditor           : {hidden: false}
        validated_on           : {hidden: true}
        self_attested          : {hidden: true}
        holder_company         : {hidden: false}
        last_test_date         : {hidden: false}
        certificates_id        : {hidden: false}
        remote_validation      : {hidden: true}
        validation_comments    : {hidden: true}
        required_for_compliance: {hidden: false}
      }
    }
  
    file? file?
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.companies_id && $db.required_certificates.document == null && $db.required_certificates.certificates_id == $input.certificates_id
      return = {type: "list"}
    } as $id
  
    db.get companies {
      field_name = "id"
      field_value = $input.companies_id
      addon = [
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "user"
        }
      ]
    } as $company
  
    db.get certificates {
      field_name = "id"
      field_value = $input.certificates_id
    } as $certificate
  
    storage.create_attachment {
      value = $input.file
      access = "public"
      filename = ""
    } as $file_attachment
  
    conditional {
      if (($id|count) != 0) {
        var.update $id {
          value = $id.id|first
        }
      
        db.edit required_certificates {
          field_name = "id"
          field_value = $id
          enforce_hidden_fields = false
          data = {
            active                 : true
            holder                 : $input.holder
            holder_company         : $input.holder_company
            issued_date            : $input.issued_date
            expiry_date            : $input.expiry_date
            issued_by              : $input.issued_by
            last_test_date         : $input.last_test_date
            test_auditor           : $input.test_auditor
            required_for_compliance: $input.required_for_compliance
            document               : $file_attachment
          }
        } as $required_certificates_2
      }
    
      else {
        db.add required_certificates {
          enforce_hidden_fields = false
          data = {
            created_at             : "now"
            companies_id           : $input.companies_id
            certificates_id        : $input.certificates_id
            active                 : true
            holder                 : $input.holder
            holder_company         : $input.holder_company
            issued_date            : $input.issued_date
            expiry_date            : $input.expiry_date
            issued_by              : $input.issued_by
            last_test_date         : $input.last_test_date
            test_auditor           : $input.test_auditor
            required_for_compliance: $input.required_for_compliance
            document               : $file_attachment
          }
        } as $required_certificates_1
      }
    }
  
    api.request {
      url = "https://p3audit.com/itracker/upload_cert_email_p3.php"
      method = "POST"
      params = {}
        |set:"c_name":$certificate.Certificate_Name
        |set:"company":$company.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  
    api.request {
      url = "https://p3audit.com/itracker/upload_cert_mail_customer.php"
      method = "POST"
      params = {}
        |set:"c_name":$certificate.Certificate_Name
        |set:"contact":$company.user.name
        |set:"u_name":$company.user.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = "Done"
}