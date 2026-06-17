query addon_user verb=POST {
  api_group = "multiple user access"
  auth = "user"

  input {
    text email? filters=trim
    text company_id? filters=trim
  }

  stack {
    db.has user {
      field_name = "email"
      field_value = $input.email|to_lower
    } as $user_1
  
    db.get companies {
      field_name = "id"
      field_value = $input.company_id
    } as $companies_1
  
    var $company_name {
      value = $companies_1.Company_Name
    }
  
    conditional {
      if ($user_1) {
        api.request {
          url = $env.emailBase
            |concat:"invite_addon_already_exists.php":""
          method = "POST"
          params = {}
            |set:"client":$company_name
            |set:"email":$input.email
          headers = []
            |push:"Content-Type: application/json"
          verify_host = false
          verify_peer = false
        } as $api_1
      }
    
      else {
        security.random_number {
          min = 10000
          max = 9999999
        } as $code
      
        db.add user {
          enforce_hidden_fields = false
          data = {
            name                 : $code
            email                : $input.email|to_lower
            is_admin             : false
            business_dev         : false
            completed_walkthrough: []
          }
        } as $user_2
      
        api.request {
          url = $env.emailBase|concat:"invite_addon.php":""
          method = "POST"
          params = {}
            |set:"client":$company_name
            |set:"code":$code
            |set:"email":$input.email
          headers = []
            |push:"Content-Type: application/json"
          verify_host = false
          verify_peer = false
        } as $api_1
      }
    }
  
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user_3
  
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company_id
    } as $subscriptions_2
  
    db.edit subscriptions {
      field_name = "company"
      field_value = $input.company_id
      enforce_hidden_fields = false
      data = {addon_user: $subscriptions_2.addon_user|push:$user_3.id}
    } as $subscriptions_1
  
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company_id
      addon = [
        {
          name : "user"
          input: {user_id: $output.$this}
          as   : "addon_user.addon_user"
        }
      ]
    } as $subscriptions_2
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = $subscriptions_2
}