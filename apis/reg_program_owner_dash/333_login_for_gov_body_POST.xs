query login_for_gov_body verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    var $status {
      value = "Invalid Credentials...Please try again"
    }
  
    var $governing_bodies {
      value = ""
    }
  
    var $auditors {
      value = ""
    }
  
    db.query certificationBody {
      return = {type: "list"}
    } as $governing_bodies
  
    db.query auditor {
      return = {type: "list"}
    } as $auditors
  
    var.update $status {
      value = "done"
    }
  }

  response = {
    status          : $status
    governing_bodies: $governing_bodies
    auditors        : $auditors
  }
}