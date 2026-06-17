query get_auditor_email_from_code verb=POST {
  api_group = "auditor_dashboard"

  input {
    text code? filters=trim
  }

  stack {
    db.get auditor {
      field_name = "code"
      field_value = $input.code
    } as $auditor_1
  }

  response = {status: $auditor_1.email}
}