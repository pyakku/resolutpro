query editAuditor verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    text fname? filters=trim
    text mname? filters=trim
    text lname? filters=trim
    text image? filters=trim
  }

  stack {
    db.edit auditor {
      field_name = "id"
      field_value = $auth.id
      enforce_hidden_fields = false
      data = {
        first_name : $input.fname
        middle_name: $input.mname
        last_name  : $input.lname
        image      : $input.image
      }
    } as $auditor1
  }

  response = {updated: $auditor1}
}