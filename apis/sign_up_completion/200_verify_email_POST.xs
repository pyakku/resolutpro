query verify_email verb=POST {
  api_group = "sign_up_completion"

  input {
    text email? filters=trim
  }

  stack {
    security.random_number {
      min = 10000
      max = 999999
    } as $code
  
    api.request {
      url = "https://p3audit.com/itracker/verify_email.php?email="
        |concat:($input.email
          |concat:("&code="|concat:$code:""):""
        ):""
      method = "GET"
    } as $api_1
  }

  response = {code: $code}
}