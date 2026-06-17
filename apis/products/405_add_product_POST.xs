query add_product verb=POST {
  api_group = "products"

  input {
    dblink {
      table = "products"
      override = {
        co                    : {hidden: true}
        coa                   : {hidden: true}
        coc                   : {hidden: true}
        isv                   : {hidden: false}
        ECCN                  : {hidden: false}
        company               : {hidden: false}
        created_at            : {hidden: true}
        product_name          : {hidden: false}
        validated_on          : {hidden: true}
        last_audit_date       : {hidden: true}
        software_auditor      : {hidden: true}
        third_party_processors: {hidden: false}
      }
    }
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
      addon = [
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "user"
        }
      ]
    } as $companies_1
  
    db.add products {
      enforce_hidden_fields = false
      data = {
        created_at            : "now"
        company               : $input.company
        isv                   : $input.isv
        product_name          : $input.product_name
        version               : $input.version
        other_identifiers     : $input.other_identifiers
        ECCN                  : $input.ECCN
        third_party_processors: $input.third_party_processors
        is_software           : $input.is_software
        certificates          : $input.certificates
      }
    } as $products_2
  
    !conditional {
      if ($input.coa_upload) {
        storage.create_attachment {
          value = $input.coa_file
          access = "public"
          filename = ""
        } as $var_1
      
        db.add required_certificates {
          enforce_hidden_fields = false
          data = {
            created_at     : "now"
            companies_id   : $input.company
            certificates_id: 141
            active         : true
            product_name   : $input.product_name
            test_auditor   : $input.software_auditor
            document       : $var_1
          }
        } as $required_certificates_1
      
        db.edit products {
          field_name = "id"
          field_value = $products_2.id
          enforce_hidden_fields = false
          data = {coa: $required_certificates_1.id}
        } as $products_1
      
        api.request {
          url = "https://p3audit.com/itracker/upload_cert_email_p3.php"
          method = "POST"
          params = {}
            |set:"c_name":"Certificate of Analysis"
            |set:"company":$companies_1.Company_Name
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
            |set:"c_name":"Certificate of Analysis"
            |set:"contact":$companies_1.user.name
            |set:"u_name":$companies_1.user.email
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api_1}
        } as $email_log_1
      }
    }
  
    !conditional {
      if ($input.coc_upload) {
        storage.create_attachment {
          value = $input.coc_file
          access = "public"
          filename = ""
        } as $var_1
      
        db.add required_certificates {
          enforce_hidden_fields = false
          data = {
            created_at     : "now"
            companies_id   : $input.company
            certificates_id: 143
            active         : true
            product_name   : $input.product_name
            test_auditor   : $input.software_auditor
            document       : $var_1
          }
        } as $required_certificates_1
      
        db.edit products {
          field_name = "id"
          field_value = $products_2.id
          enforce_hidden_fields = false
          data = {coc: $required_certificates_1.id}
        } as $products_1
      
        api.request {
          url = "https://p3audit.com/itracker/upload_cert_email_p3.php"
          method = "POST"
          params = {}
            |set:"c_name":"Certificate of Compliance"
            |set:"company":$companies_1.Company_Name
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
            |set:"c_name":"Certificate of Compliance"
            |set:"contact":$companies_1.user.name
            |set:"u_name":$companies_1.user.email
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api_1}
        } as $email_log_1
      }
    }
  
    !conditional {
      if ($input.coo_upload) {
        storage.create_attachment {
          value = $input.coo_file
          access = "public"
          filename = ""
        } as $var_1
      
        db.add required_certificates {
          enforce_hidden_fields = false
          data = {
            created_at     : "now"
            companies_id   : $input.company
            certificates_id: 142
            active         : true
            product_name   : $input.product_name
            test_auditor   : $input.software_auditor
            document       : $var_1
          }
        } as $required_certificates_1
      
        db.edit products {
          field_name = "id"
          field_value = $products_2.id
          enforce_hidden_fields = false
          data = {co: $required_certificates_1.id}
        } as $products_1
      
        api.request {
          url = "https://p3audit.com/itracker/upload_cert_email_p3.php"
          method = "POST"
          params = {}
            |set:"c_name":"Certificate of Origin"
            |set:"company":$companies_1.Company_Name
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
            |set:"c_name":"Certificate of Origin"
            |set:"contact":$companies_1.user.name
            |set:"u_name":$companies_1.user.email
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

  response = "Done"
}