query auditStatus verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    conditional {
      if ($audit1.completed_on != null) {
        var $completed {
          value = true
        }
      }
    
      else {
        var $completed {
          value = false
        }
      }
    }
  }

  response = {completed: $completed}
}