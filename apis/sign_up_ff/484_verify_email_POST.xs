query verifyEmail verb=POST {
  api_group = "Sign Up FF"

  input {
    text code? filters=trim
    text email? filters=trim
  }

  stack {
    api.request {
      url = $env.emailBase
        |concat:("verifyEmail.php?email="
          |concat:($input.email
            |url_encode
            |concat:("&code="|concat:$input.code:""):""
          ):""
        ):""
      method = "GET"
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $api1
}