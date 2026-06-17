addon notification_settings_of_companies_by_company {
  input {
    int companies_id? {
      table = "companies"
    }
  }

  stack {
    db.query notification_settings {
      where = $db.notification_settings.companies_id == $input.companies_id
      return = {type: "single"}
    }
  }
}