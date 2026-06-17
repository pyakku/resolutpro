query changePassword verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    text password? filters=trim
  }

  stack {
    db.edit auditor {
      field_name = "id"
      field_value = $auth.id
      enforce_hidden_fields = false
      data = {password: $input.password}
    } as $auditor2
  }

  response = null
}