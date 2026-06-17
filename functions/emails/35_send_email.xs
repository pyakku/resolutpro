function "Emails/send_email" {
  input {
    text to? filters=trim
    text subject? filters=trim
    text message_html? filters=trim
  }

  stack {
    api.request {
      url = "https://itrackersignup.p3audit.com/emailAPIs/send_emailp3.php"
      method = "POST"
      params = {}
        |set:"to":$input.to
        |set:"subject":$input.subject
        |set:"message_html":$input.message_html
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $api1
}