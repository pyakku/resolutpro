query edit_certificate verb=POST {
  api_group = "certificates_new"

  input {
    text id? filters=trim
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
  
    bool file_change?
    file? file?
  }

  stack {
    db.get required_certificates {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $input.companies_id}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "user"
            }
          ]
          as   : "company"
        }
        {
          name : "certificates"
          input: {certificates_id: $output.certificates_id}
          as   : "certificate"
        }
      ]
    } as $required_certificates_2
  
    conditional {
      if ($input.file_change) {
        storage.create_attachment {
          value = $input.file
          access = "public"
          filename = ""
        } as $var_1
      
        db.edit required_certificates {
          field_name = "id"
          field_value = $input.id
          enforce_hidden_fields = false
          data = {
            holder        : $input.holder
            holder_company: $input.holder_company
            issued_date   : $input.issued_date
            expiry_date   : $input.expiry_date
            issued_by     : $input.issued_by
            last_test_date: $input.last_test_date
            test_auditor  : $input.test_auditor
            p3_audited    : false
            validated_on  : null
            rejected      : false
            document      : $var_1
          }
        } as $required_certificates_3
      
        storage.delete_file {
          pathname = $required_certificates_2.document.path
        }
      }
    
      else {
        db.edit required_certificates {
          field_name = "id"
          field_value = $input.id
          enforce_hidden_fields = false
          data = {
            holder        : $input.holder
            holder_company: $input.holder_company
            issued_date   : $input.issued_date
            expiry_date   : $input.expiry_date
            issued_by     : $input.issued_by
            last_test_date: $input.last_test_date
            test_auditor  : $input.test_auditor
            p3_audited    : false
            validated_on  : null
            rejected      : false
          }
        } as $required_certificates_3
      }
    }
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.companies_id && $db.required_certificates.active == true && $db.required_certificates.document != null
      return = {type: "list"}
      addon = [
        {
          name  : "certificates"
          output: [
            "id"
            "Certificate_Name"
            "Certificate_Desc"
            "type"
            "logo.access"
            "logo.path"
            "logo.name"
            "logo.type"
            "logo.size"
            "logo.mime"
            "logo.meta"
            "logo.url"
          ]
          input : {certificates_id: $output.certificates_id}
          addon : [
            {
              name  : "certificate_types"
              output: ["id", "type"]
              input : {certificate_types_id: $output.type}
              as    : "type"
            }
          ]
          as    : "certificates_id"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.holder}
          as   : "holder"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.holder_company}
          as   : "holder_company"
        }
      ]
    } as $required_certificates_1
  
    api.request {
      url = "https://p3audit.com/itracker/edit_cert_email_p3.php"
      method = "POST"
      params = {}
        |set:"c_name":$required_certificates_2.certificate.Certificate_Name
        |set:"company":$required_certificates_2.company.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  
    api.request {
      url = "https://p3audit.com/itracker/edit_cert_mail_customer.php"
      method = "POST"
      params = {}
        |set:"c_name":$required_certificates_2.certificate.Certificate_Name
        |set:"contact":$required_certificates_2.company.user.name
        |set:"u_name":$required_certificates_2.company.user.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  
    var $return {
      value = []
    }
  
    foreach ($required_certificates_1) {
      each as $item {
        var $cname {
          value = $item.certificates_id.Certificate_Name
        }
      
        var $thisone {
          value = $item|set:"cert_name":$cname
        }
      
        var.update $return {
          value = $return|push:$thisone
        }
      }
    }
  }

  response = $return|sort:"cert_name":"itext":true
}