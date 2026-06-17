query get_audit_report verb=POST {
  api_group = "audit_report"

  input {
    text id? filters=trim
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name  : "certificates"
          output: ["Certificate_Name"]
          input : {certificates_id: $output.id}
          as    : "certificates"
        }
        {
          name  : "policies"
          output: ["name"]
          input : {policies_id: $output.id}
          as    : "policies"
        }
        {
          name : "relationships"
          input: {relationships_id: $output.id}
          addon: [
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.assigned_to}
              as    : "assigned_to"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.assigned_by}
              as    : "assigned_by"
            }
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.data_owner}
              as    : "data_owner"
            }
          ]
          as   : "processes.process"
        }
        {
          name  : "companies_01"
          output: ["Company_Name", "phone_number", "verified"]
          input : {companies_id: $output.companies_id}
        }
        {
          name : "auditor"
          input: {auditor_id: $output.auditor_id}
          as   : "auditor"
        }
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          as   : "audit_type"
        }
      ]
    } as $audit_1
  
    db.query relationships {
      where = $db.relationships.assigned_by == $audit_1.companies_id || $db.relationships.data_owner == $audit_1.companies_id
      return = {type: "list"}
    } as $relationships_1
  
    var $total_suppliers {
      value = 0
    }
  
    var $average {
      value = 0
    }
  
    conditional {
      if (($relationships_1|count) == 0) {
      }
    
      else {
        var.update $total_suppliers {
          value = $relationships_1.assigned_to|unique:""|count
        }
      
        var.update $average {
          value = $relationships_1.PTN_no|unique:""|count
        }
      
        var.update $average {
          value = $relationships_1|count|divide:$average
        }
      }
    }
  }

  response = {
    report         : $audit_1
    total_suppliers: $total_suppliers
    average        : $average
  }
}