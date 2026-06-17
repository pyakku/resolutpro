query resetPassword verb=POST {
  api_group = "Auditor FF"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.edit auditor {
      field_name = "email"
      field_value = $input.email
      enforce_hidden_fields = false
      data = {password: $input.password, code: ""}
    } as $auditor1
  }

  response = $auditor1
}