query editAuditorProfile verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text first_name? filters=trim
    text middle_name? filters=trim
    text last_name? filters=trim
    text email? filters=trim
    int id?
    bool independent?
  }

  stack {
    db.edit auditor {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        first_name : $input.first_name
        middle_name: $input.middle_name
        last_name  : $input.last_name
        email      : $input.email
        independent: $input.independent
        employed   : $input.independent|not
      }
    } as $auditor1
  }

  response = $auditor1
}