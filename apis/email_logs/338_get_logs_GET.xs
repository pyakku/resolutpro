query get_logs verb=GET {
  api_group = "Email Logs"

  input {
  }

  stack {
    db.query email_log {
      return = {type: "list"}
    } as $email_log_1
  }

  response = $email_log_1
}