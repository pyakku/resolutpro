query getEmailLogs verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query email_log {
      sort = {email_log.created_at: "desc"}
      return = {type: "list"}
    } as $email_log1
  }

  response = $email_log1
}