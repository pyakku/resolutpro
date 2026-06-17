query setNotificationSettingsHolder verb=POST {
  api_group = "ffNotifications"
  auth = "user"

  input {
    int company?
    bool holder?
  }

  stack {
    db.add_or_edit notification_settings {
      field_name = "companies_id"
      field_value = $input.company
      enforce_hidden_fields = false
      data = {holder: $input.holder}
    } as $notification_settings1
  }

  response = $notification_settings1
}