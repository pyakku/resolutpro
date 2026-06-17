query view_all_auditors_governing_body verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text reg_body? filters=trim
  }

  stack {
    !db.query certificationBody {
      where = $db.certificationBody.reg_program_owner == $input.reg_body
      return = {type: "list"}
    } as $governing_body_1
  
    !var $var_1 {
      value = $governing_body_1|get:"id":null
    }
  
    db.query auditor {
      where = $input.reg_body in $db.auditor.governing_body
      return = {type: "list"}
      addon = [
        {
          name : "governing_body"
          input: {governing_body_id: $output.$this}
          as   : "governing_body"
        }
      ]
    } as $auditor_1
  }

  response = $auditor_1
}