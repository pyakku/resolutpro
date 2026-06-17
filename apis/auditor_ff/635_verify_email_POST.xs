query verifyEmail verb=POST {
  api_group = "Auditor FF"

  input {
    text email? filters=trim
    text code? filters=trim
  }

  stack {
    db.get auditor {
      field_name = "email"
      field_value = $input.email
    } as $auditor1
  
    precondition (($auditor1|is_empty) == false)
    api.request {
      url = $env.emailBase
        |concat:"auditorVerifyEmailForReset.php":""
      method = "POST"
      params = {}
        |set:"otp":$input.code
        |set:"email":$input.email
        |set:"firstName":$auditor1.first_name
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $api1
}