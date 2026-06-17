query auditor_login verb=POST {
  api_group = "auditor_dashboard"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.get auditor {
      field_name = "email"
      field_value = $input.email
      output = ["id", "created_at", "first_name", "last_name", "email", "password"]
    } as $auditor_1
  
    var $return {
      value = "error"
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $auditor_1.password
    } as $correct
  
    conditional {
      if ($correct) {
        db.get auditor {
          field_name = "email"
          field_value = $input.email
        } as $auditor_details
      
        db.query audit {
          where = $db.audit.auditor_id == $auditor_details.id
          return = {type: "list"}
          addon = [
            {
              name : "companies"
              input: {companies_id: $output.companies_id}
              as   : "company"
            }
            {
              name : "audit_types"
              input: {audit_types_id: $output.audit_types_id}
              as   : "audit_type"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.companies_id}
            }
          ]
        } as $audit_details
      
        var.update $return {
          value = "done"
        }
      }
    
      else {
        var $auditor_details {
          value = ""
        }
      
        var $audit_details {
          value = ""
        }
      }
    }
  }

  response = {
    return         : $return
    auditor_details: $auditor_details
    audit_details  : $audit_details
  }
}