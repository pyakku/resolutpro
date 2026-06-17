query completeAudit verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    text status? filters=trim
    int auditID?
    text auditComments? filters=trim
    text actionDetails? filters=trim
  }

  stack {
    var $actionRequired {
      value = false
    }
  
    var $passed {
      value = false
    }
  
    var $failed {
      value = false
    }
  
    var $actionComments {
      value = ""
    }
  
    conditional {
      if ($input.status == "Action Required") {
        var.update $actionRequired {
          value = true
        }
      
        var.update $actionComments {
          value = $input.actionDetails
        }
      }
    }
  
    conditional {
      if ($input.status == "Pass") {
        var.update $passed {
          value = true
        }
      }
    }
  
    conditional {
      if ($input.status == "Fail") {
        var.update $failed {
          value = true
        }
      }
    }
  
    db.edit audit {
      field_name = "id"
      field_value = $input.auditID
      enforce_hidden_fields = false
      data = {
        passed         : $passed
        failed         : $failed
        comments       : $input.auditComments
        completed_on   : now
        action_required: $actionRequired
        action_comments: $actionComments
      }
    } as $audit1
  
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
      addon = [
        {
          name  : "audit_types"
          output: ["type"]
          input : {audit_types_id: $output.audit_types_id}
        }
      ]
    } as $audit2
  
    db.get companies {
      field_name = "id"
      field_value = $audit2.companies_id
    } as $companies1
  
    db.get user {
      field_name = "id"
      field_value = $companies1.created_by_user
    } as $user1
  
    db.get auditor {
      field_name = "id"
      field_value = $auth.id
    } as $auditor1
  
    api.request {
      url = "https://itrackersignup.p3audit.com/emailAPIs/auditCompletedEmailToCustomer.php"
      method = "POST"
      params = {}
        |set:"contactFirstName":$user1.name
        |set:"auditName":$audit2.type
        |set:"auditorName":($auditor1.first_name|concat:$auditor1.last_name:" ")
        |set:"companyName":$companies1.Company_Name
        |set:"status":$input.status
        |set:"completedOn":(now|format_timestamp:"d F Y":"UTC")
        |set:"actionRequired":$actionRequired
        |set:"email":$user1.email
        |set:"comments":$input.auditComments
        |set:"action":$input.actionDetails
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $audit1
}