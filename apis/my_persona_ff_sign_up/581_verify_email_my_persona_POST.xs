query verifyEmailMyPersona verb=POST {
  api_group = "myPersonaFFSignUp"

  input {
    text email? filters=trim
    text code? filters=trim
  }

  stack {
    api.request {
      url = $env.emailBase
        |concat:"myPersonaVerifyEmail.php":""
      method = "POST"
      params = {}
        |set:"email":$input.email
        |set:"otp":$input.code
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $api1
}