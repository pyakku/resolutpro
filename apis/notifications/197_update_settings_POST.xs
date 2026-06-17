query update_settings verb=POST {
  api_group = "notifications"

  input {
    dblink {
      table = "notification_settings"
      override = {
        on           : {hidden: false}
        holder       : {hidden: false}
        one_day      : {hidden: false}
        one_hour     : {hidden: false}
        created_at   : {hidden: true}
        seven_days   : {hidden: false}
        sixty_days   : {hidden: false}
        ninety_days  : {hidden: false}
        thirty_days  : {hidden: false}
        companies_id : {hidden: false}
        fourteen_days: {hidden: false}
      }
    }
  }

  stack {
    db.edit notification_settings {
      field_name = "companies_id"
      field_value = $input.companies_id
      enforce_hidden_fields = false
      data = {
        ninety_days  : $input.ninety_days
        sixty_days   : $input.sixty_days
        thirty_days  : $input.thirty_days
        fourteen_days: $input.fourteen_days
        seven_days   : $input.seven_days
        one_day      : $input.one_day
        one_hour     : $input.one_hour
        holder       : $input.holder
        on           : $input.on
      }
    } as $notification_settings_1
  }

  response = $notification_settings_1
}