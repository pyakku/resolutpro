query add_new_company_login_page verb=POST {
  api_group = "sign_upv3"

  input {
    int user?
    text key? filters=trim
  }

  stack {
    db.has add_company_from_login_page {
      field_name = "user"
      field_value = $input.user
    } as $add_company_from_login_page_3
  
    conditional {
      if ($add_company_from_login_page_3) {
        db.edit add_company_from_login_page {
          field_name = "user"
          field_value = $input.user
          enforce_hidden_fields = false
          data = {valid_till: now|add_secs_to_timestamp:60}
        } as $add_company_from_login_page_4
      }
    
      else {
        db.add add_company_from_login_page {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            user      : $input.user
            valid_till: now|add_secs_to_timestamp:60
            key       : $input.key
          }
        } as $add_company_from_login_page_1
      }
    }
  }

  response = $add_company_from_login_page_3
}