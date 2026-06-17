query request_certificate verb=POST {
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
        certificates_id        : {hidden: true}
        remote_validation      : {hidden: true}
        validation_comments    : {hidden: true}
        required_for_compliance: {hidden: true}
      }
    }
  
    file? file?
    text certificate_name? filters=trim
  }

  stack {
    storage.create_attachment {
      value = $input.file
      access = "public"
      filename = ""
    } as $file_attachment
  
    db.transaction {
      stack {
        group {
          stack {
            db.add certificates {
              enforce_hidden_fields = false
              data = {
                created_at      : "now"
                Certificate_Name: $input.certificate_name
                approved        : false
              }
            } as $certificates_1
          
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
          
            db.add certificate_request {
              enforce_hidden_fields = false
              data = {
                created_at          : "now"
                requested_by        : $company.user.id
                c_name              : $input.certificate_name
                attachment          : $input.file
                requested_by_company: $input.companies_id
              }
            } as $certificate_request_1
          
            storage.create_attachment {
              value = $input.file
              access = "public"
              filename = ""
            } as $file_attachment
          
            db.add required_certificates {
              enforce_hidden_fields = false
              data = {
                created_at             : "now"
                companies_id           : $input.companies_id
                certificates_id        : $certificates_1.id
                active                 : true
                holder                 : $input.holder
                holder_company         : $input.holder_company
                issued_date            : $input.issued_date
                expiry_date            : $input.expiry_date
                issued_by              : $input.issued_by
                last_test_date         : $input.last_test_date
                test_auditor           : $input.test_auditor
                required_for_compliance: false
                document               : $file_attachment
              }
            } as $required_certificates_1
          
            api.request {
              url = "https://p3audit.com/itracker/upload_cert_email_p3.php"
              method = "POST"
              params = {}
                |set:"c_name":$input.certificate_name
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
                |set:"c_name":$input.certificate_name
                |set:"contact":$company.user.name
                |set:"u_name":$company.user.email
              headers = []
                |push:"Content-Type: application/json"
            } as $api_1
          
            db.add email_log {
              enforce_hidden_fields = false
              data = {created_at: "now", response: $api_1}
            } as $email_log_1
          
            api.request {
              url = "https://p3audit.com/itracker/mail_request_certificate_to_requester.php"
              method = "POST"
              params = {}
                |set:"certificate":$input.certificate_name
                |set:"to":$company.user.name
                |set:"email":$company.user.email
              headers = []
                |push:"Content-Type: application/json"
            } as $api_1
          
            db.add email_log {
              enforce_hidden_fields = false
              data = {created_at: "now", response: $api_1}
            } as $email_log_1
          
            api.request {
              url = "https://p3audit.com/itracker/mail_request_certificate.php"
              method = "POST"
              params = {}
                |set:"certificate":$input.certificate_name
                |set:"by":$company.Company_Name
              headers = []
                |push:"Content-Type: application/json"
            } as $api_1
          
            db.add email_log {
              enforce_hidden_fields = false
              data = {created_at: "now", response: $api_1}
            } as $email_log_1
          }
        }
      }
    }
  }

  response = "Done"
}