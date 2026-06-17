query view_auditors verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text governing_body? filters=trim
  }

  stack {
    var $g_body {
      value = $input.governing_body|to_int
    }
  
    db.query auditor {
      where = $g_body in $db.auditor.governing_body
      return = {type: "list"}
    } as $auditor_1
  }

  response = $auditor_1
}