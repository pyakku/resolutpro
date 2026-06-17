query get_settings verb=POST {
  api_group = "notifications"

  input {
    text company_id? filters=trim
  }

  stack {
    db.has notification_settings {
      field_name = "companies_id"
      field_value = $input.company_id
    } as $has
  
    conditional {
      if ($has) {
        db.get notification_settings {
          field_name = "companies_id"
          field_value = $input.company_id
        } as $notification_settings_1
      }
    
      else {
        db.add notification_settings {
          enforce_hidden_fields = false
          data = {
            companies_id : $input.company_id|to_int
            ninety_days  : false
            sixty_days   : false
            thirty_days  : false
            fourteen_days: false
            seven_days   : false
            one_day      : false
            one_hour     : false
            holder       : false
          }
        } as $notification_settings_1
      }
    }
  }

  response = $notification_settings_1
}