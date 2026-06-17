query getNotificationSettings verb=POST {
  api_group = "ffNotifications"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get notification_settings {
      field_name = "companies_id"
      field_value = $input.company
    } as $notification_settings1
  
    conditional {
      if ($notification_settings1|is_empty) {
        db.add notification_settings {
          enforce_hidden_fields = false
          data = {
            created_at  : "now"
            companies_id: $input.company
            settings    : []|push:"90 Days"|push:"60 Days"|push:"30 Days"|push:"14 Days"|push:"7 Days"|push:"1 Day"|push:"1 Hour"|push:"Expired"
          }
        } as $notification_settings2
      }
    }
  
    db.get notification_settings {
      field_name = "companies_id"
      field_value = $input.company
    } as $notification_settings1
  
    var $holder {
      value = $notification_settings1.holder
    }
  
    var.update $notification_settings1 {
      value = $notification_settings1.settings
    }
  }

  response = {settings: $notification_settings1, holder: $holder}
}