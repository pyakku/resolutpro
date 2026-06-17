query update_company_owner verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
    text user_email? filters=trim
  }

  stack {
    var $return {
      value = ""
    }
  
    db.has user {
      field_name = "email"
      field_value = $input.user_email
    } as $user_1
  
    conditional {
      if ($user_1) {
        db.get user {
          field_name = "email"
          field_value = $input.user_email
        } as $user_2
      
        db.edit companies {
          field_name = "id"
          field_value = $input.company_id
          enforce_hidden_fields = false
          data = {created_by_user: $user_2.id}
        } as $companies_1
      
        var.update $return {
          value = "Updated Successfully"
        }
      }
    
      else {
        var.update $return {
          value = "User Email Not found"
        }
      }
    }
  }

  response = {response: $return}
}