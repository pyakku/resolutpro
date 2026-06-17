function create_log {
  input {
    text action? filters=trim
    int company?
    int user?
  }

  stack {
    db.add logs {
      enforce_hidden_fields = false
      data = {
        created_at  : "now"
        companies_id: $input.company
        user_id     : $input.user
        action      : $input.action
      }
    } as $logs_1
  }

  response = null
}