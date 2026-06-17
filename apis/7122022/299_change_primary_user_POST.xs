query change_primary_user verb=POST {
  api_group = "7122022"

  input {
    text company? filters=trim
    text user_id? filters=trim
    text old_user? filters=trim
    text password? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $input.old_user
      output = [
        "id"
        "created_at"
        "name"
        "l_name"
        "email"
        "password"
        "user_id"
        "profile_img"
        "language"
        "date_format"
        "is_admin"
        "plan"
        "business_dev"
      ]
    } as $user_1
  
    db.get user {
      field_name = "id"
      field_value = $input.user_id
    } as $user_2
  
    security.check_password {
      text_password = $input.password
      hash_password = $user_1.password
    } as $var_1
  
    var $status {
      value = "You've entered a wrong password."
    }
  
    conditional {
      if ($var_1) {
        db.get subscriptions {
          field_name = "company"
          field_value = $input.company
        } as $subscriptions_2
      
        db.edit companies {
          field_name = "id"
          field_value = $input.company
          enforce_hidden_fields = false
          data = {created_by_user: $input.user_id|to_int}
        } as $companies_1
      
        db.edit subscriptions {
          field_name = "company"
          field_value = $input.company
          enforce_hidden_fields = false
          data = {
            user_id   : $input.user_id|to_int
            addon_user: $subscriptions_2.addon_user|remove:($input.user_id|to_int):"":false
          }
        } as $subscriptions_1
      
        db.edit subscriptions {
          field_name = "company"
          field_value = $input.company
          enforce_hidden_fields = false
          data = {
            user_id   : $input.user_id|to_int
            addon_user: $subscriptions_1.addon_user|push:($input.old_user|to_int)
          }
        } as $subscriptions_1
      
        var.update $status {
          value = "Primary User Changed Successfully."
        }
      
        api.request {
          url = "https://p3audit.com/itracker/change_system_user_email.php"
          method = "POST"
          params = {}
            |set:"primary_name":$user_2.name
            |set:"primary_email":$user_2.email
            |set:"company_name":$companies_1.Company_Name
            |set:"removed_name":($user_1.name
              |concat:(" "|concat:$user_1.l_name:""):""
            )
            |set:"removed_email":$user_1.email
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      }
    }
  }

  response = $status
}