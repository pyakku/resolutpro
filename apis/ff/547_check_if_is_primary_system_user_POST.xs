query checkIfIsPrimarySystemUser verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
    } as $subscriptions1
  
    conditional {
      if ($subscriptions1.user_id == $auth.id) {
        var $primary {
          value = true
        }
      }
    
      else {
        var $primary {
          value = false
        }
      }
    }
  }

  response = {primary: $primary}
}