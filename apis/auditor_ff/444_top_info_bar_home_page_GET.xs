query top_info_bar_home_page verb=GET {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
  }

  stack {
    var $audits {
      value = 0
    }
  
    var $completed {
      value = 0
    }
  
    var $pending {
      value = 0
    }
  
    var $certificates {
      value = 0
    }
  
    db.query audit {
      where = $db.audit.auditor_id == $auth.id
      return = {type: "count"}
    } as $audits
  
    db.query audit {
      where = $db.audit.auditor_id == $auth.id && $db.audit.completed_on != null
      return = {type: "count"}
    } as $completed
  
    db.query audit {
      where = $db.audit.auditor_id == $auth.id && $db.audit.completed_on == null
      return = {type: "count"}
    } as $pending
  
    db.query auditor_certificates {
      where = $db.auditor_certificates.auditor_id == $auth.id
      return = {type: "count"}
    } as $certificates
  }

  response = {
    audits      : $audits
    completed   : $completed
    pending     : $pending
    certificates: $certificates
  }
}