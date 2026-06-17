query check_auditor_exists verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text email? filters=trim
  }

  stack {
    db.has auditor {
      field_name = "email"
      field_value = $input.email
    } as $auditor_1
  }

  response = $auditor_1
}