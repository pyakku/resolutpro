query check_director_verification verb=POST {
  api_group = "sign_upv3"

  input {
    text company? filters=trim
  }

  stack {
    var $return {
      value = false
    }
  
    db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies_1
  
    conditional {
      if ($companies_1.verified) {
        var.update $return {
          value = true
        }
      }
    }
  }

  response = $return
}