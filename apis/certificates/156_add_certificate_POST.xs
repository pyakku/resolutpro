query add_certificate verb=POST {
  api_group = "Certificates"

  input {
    text details? filters=trim
    text issuing_body? filters=trim
    text holder_id? filters=trim
    text issued_date? filters=trim
    text expiry_date? filters=trim
    text cert_id_regulatory? filters=trim
    bool is_regulatory?=false
    int company_id?
    bool request_new?=false
    file document?
    text last_test_date? filters=trim
    text test_auditor? filters=trim
  }

  stack {
    var $return_var {
      value = ""
    }
  
    storage.create_attachment {
      value = $input.document
      access = "public"
    } as $document_upload
  
    conditional {
      if ($input.is_regulatory) {
        conditional {
          if ($input.request_new) {
            db.add certificates {
              enforce_hidden_fields = false
              data = {Certificate_Name: $input.details, approved: false}
              output = [
                "id"
                "created_at"
                "Certificate_Name"
                "Certificate_Desc"
                "details"
                "q1"
                "q2"
                "q3"
                "q4"
                "q5"
                "approved"
                "logo.path"
                "logo.name"
                "logo.type"
                "logo.size"
                "logo.mime"
                "logo.meta"
                "logo.url"
              ]
            } as $certificates_1
          
            var $cert_id_for_new_request {
              value = $certificates_1.id
            }
          
            db.add required_certificates {
              enforce_hidden_fields = false
              data = {
                companies_id           : $input.company_id
                certificates_id        : $cert_id_for_new_request|to_int
                active                 : true
                holder                 : $input.holder_id|to_int
                issued_date            : $input.issued_date
                expiry_date            : $input.expiry_date
                issued_by              : $input.issuing_body
                last_test_date         : $input.last_test_date
                test_auditor           : $input.test_auditor
                required_for_compliance: false
                self_attested          : false
                remote_validation      : false
                p3_audited             : false
                document               : $document_upload
              }
            } as $required_certificates_1
          
            var.update $return_var {
              value = "New Certificate Request Placed"
            }
          }
        
          else {
            db.add required_certificates {
              enforce_hidden_fields = false
              data = {
                companies_id           : $input.company_id
                certificates_id        : $input.cert_id_regulatory|to_int
                active                 : true
                holder                 : $input.holder_id|to_int
                issued_date            : $input.issued_date
                expiry_date            : $input.expiry_date
                issued_by              : $input.issuing_body
                last_test_date         : $input.last_test_date
                test_auditor           : $input.test_auditor
                required_for_compliance: false
                self_attested          : false
                remote_validation      : false
                p3_audited             : false
                sla_extender           : "0"
                document               : $document_upload
              }
            } as $required_certificates_1
          
            var.update $return_var {
              value = "Regulatory Certificate Uploaded"
            }
          }
        }
      }
    
      else {
        db.add other_certificates {
          enforce_hidden_fields = false
          data = {
            company_id    : $input.company_id
            details       : $input.details
            auth_body     : $input.issuing_body
            holder        : $input.holder_id|to_int
            last_test_date: $input.last_test_date
            test_auditor  : $input.test_auditor
            issued_date   : $input.issued_date
            expiry_date   : $input.expiry_date
            document      : $document_upload
          }
        } as $other_certificates_1
      
        var.update $return_var {
          value = "Successfully Added Non-Regulatory Certificate"
        }
      }
    }
  }

  response = {Status: $return_var}
}