query audit_by_date verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    text date? filters=trim
  }

  stack {
    db.query audit {
      where = $db.audit.due_by == $input.date && ($db.audit.auditor_id == $auth.id || $db.audit.override == $auth.id)
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
        {
          name  : "audit_types"
          output: ["type"]
          input : {audit_types_id: $output.audit_types_id}
        }
      ]
    } as $audit1
  
    var $count {
      value = $audit1|count
    }
  
    var $exists {
      value = false
    }
  
    conditional {
      if ($count != 0) {
        var.update $exists {
          value = true
        }
      }
    }
  }

  response = {audit: $audit1|first, count: $count, exists: $exists}
}