query get_addon_detail verb=POST {
  api_group = "multiple user access"
  auth = "user"

  input {
    text company_id? filters=trim
  }

  stack {
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company_id
      addon = [
        {
          name  : "user"
          output: [
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
            "completed_walkthrough"
          ]
          input : {user_id: $output.$this}
          as    : "addon_user"
        }
        {
          name : "user"
          input: {user_id: $output.user_id}
          as   : "user"
        }
      ]
    } as $subscriptions_1
  
    var $addonUser {
      value = []
    }
  
    conditional {
      if ($subscriptions_1.addon_user|is_empty) {
      }
    
      else {
        foreach ($subscriptions_1.addon_user) {
          each as $item {
            conditional {
              if ($item.password|is_empty) {
                var.update $addonUser {
                  value = $addonUser
                    |push:($item|set:"name":$item.email)
                }
              }
            
              else {
                var.update $addonUser {
                  value = $addonUser|push:$item
                }
              }
            }
          }
        }
      }
    }
  }

  response = $addonUser
    |sort:"name":"itext":true
    |unshift:($subscriptions_1.user|set:"primary":true)
}