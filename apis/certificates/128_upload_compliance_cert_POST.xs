query upload_compliance_cert verb=POST {
  api_group = "Certificates"

  input {
    file? document?
    text id? filters=trim
  }

  stack {
    storage.create_attachment {
      value = $input.document
      access = "public"
    } as $var_1
  
    db.get required_certificates {
      field_name = "id"
      field_value = $input.id
    } as $required_certificates_3
  
    conditional {
      if ($required_certificates_3.document == null) {
        db.edit required_certificates {
          field_name = "id"
          field_value = $input.id
          enforce_hidden_fields = false
          data = {active: true, document: $var_1}
        } as $required_certificates_2
      }
    
      else {
        db.edit required_certificates {
          field_name = "id"
          field_value = $input.id
          enforce_hidden_fields = false
          data = {active: false}
        } as $required_certificates_1
      
        db.add required_certificates {
          enforce_hidden_fields = false
          data = {
            companies_id           : $required_certificates_3|get:"companies_id":null
            certificates_id        : $required_certificates_3|get:"certificates_id":null
            active                 : true
            holder                 : $required_certificates_3|get:"holder":null
            issued_by              : $required_certificates_3|get:"issued_by":null
            required_for_compliance: $required_certificates_3|get:"required_for_compliance":null
            self_attested          : true
            remote_validation      : false
            p3_audited             : false
            sla_extender           : "0"
            document               : $var_1
          }
        } as $required_certificates_2
      }
    }
  }

  response = $required_certificates_2
}