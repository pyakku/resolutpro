query validate_fail_certificate verb=POST {
  api_group = "auditor_dashboard"

  input {
    text id? filters=trim
    bool validate?
    text comment? filters=trim
    text audit_id? filters=trim
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.audit_id
    } as $audit_1
  
    var $found_in_db {
      value = false
    }
  
    var $certificate_list {
      value = $audit_1.certificates
    }
  
    var $new_certificate_list {
      value = []
    }
  
    foreach ($certificate_list) {
      each as $item {
        var $row {
          value = {}
        }
      
        conditional {
          if ($item.id == $input.id) {
            var.update $row {
              value = {}
                |set:"id":$input.id
                |set:"comment":$input.comment
                |set:"validated":$input.validate
            }
          
            var.update $found_in_db {
              value = true
            }
          }
        
          else {
            var.update $row {
              value = $item
            }
          }
        }
      
        var.update $new_certificate_list {
          value = $new_certificate_list|push:$row
        }
      }
    }
  
    conditional {
      if ($found_in_db == false) {
        var.update $new_certificate_list {
          value = $new_certificate_list
            |push:({}
              |set:"id":$input.id
              |set:"validated":$input.validate
              |set:"comment":$input.comment
            )
        }
      }
    }
  
    db.edit audit {
      field_name = "id"
      field_value = $input.audit_id
      enforce_hidden_fields = false
      data = {certificates: $new_certificate_list}
    } as $audit_2
  
    db.get audit {
      field_name = "id"
      field_value = $input.audit_id
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_type"
        }
      ]
    } as $audit_3
  }

  response = $audit_3
}