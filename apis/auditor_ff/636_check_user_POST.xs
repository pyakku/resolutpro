query checkUser verb=POST {
  api_group = "Auditor FF"

  input {
    text email? filters=trim
  }

  stack {
    db.has auditor {
      field_name = "email"
      field_value = $input.email
    } as $auditor1
  }

  response = {exists: $auditor1}
}