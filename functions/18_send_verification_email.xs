function send_verification_email {
  input {
    text verifier_name? filters=trim
    text verifier_email? filters=trim
    text user_name? filters=trim
    text cid? filters=trim
    text company? filters=trim
  }

  stack {
    api.request {
      url = "https://p3audit.com/itracker/send_company_verification_email.php"
      method = "POST"
      params = {}
        |set:"email":$input.verifier_email
        |set:"username":$input.user_name
        |set:"cid":$input.cid
        |set:"name":$input.verifier_name
        |set:"company":$input.company
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = $api_1
}