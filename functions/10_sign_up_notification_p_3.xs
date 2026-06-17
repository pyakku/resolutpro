function sign_up_notification_p3 {
  input {
    text name? filters=trim
    text plan? filters=trim
    text email? filters=trim
    text phone? filters=trim
    text address? filters=trim
    text user? filters=trim
  }

  stack {
    api.request {
      url = "https://p3audit.com/itracker/sign_up_notification_p3.php"
      method = "POST"
      params = {}
        |set:"company":$input.name
        |set:"email":$input.email
        |set:"phone":$input.phone
        |set:"plan":$input.plan
        |set:"user":$input.user
        |set:"address":$input.address
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