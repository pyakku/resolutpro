query "auth/me" verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    bool isWeb?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
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
        "completed_walkthrough"
      ]
    } as $user1
  
    db.query companies {
      where = $db.companies.created_by_user == $user1.id && $db.companies.individual == true
      return = {type: "list"}
    } as $companies1
  
    precondition (($companies1|is_empty) == false) {
      error_type = "accessdenied"
    }
  
    !security.create_auth_token {
      table = "auditor"
      extras = {}
      expiration = 86400
      id = $user1.id
    } as $authToken
  
    db.get contacts {
      field_name = "email"
      field_value = $user1.email
    } as $contacts1
  
    conditional {
      if ($input.isWeb) {
        conditional {
          if ($user1.profile_img|istarts_with:"data") {
            var.update $user1 {
              value = $user1
                |set:"profile_img":$user1.profile_img
            }
          }
        
          else {
            var.update $user1 {
              value = $user1
                |set:"profile_img":("data:image/jpeg;base64,"|concat:$user1.profile_img:"")
            }
          }
        }
      }
    
      else {
        conditional {
          if ($user1.profile_img|istarts_with:"data") {
            var.update $user1 {
              value = $user1
                |set:"profile_img":($user1.profile_img|split:","|last)
            }
          }
        
          else {
            var.update $user1 {
              value = $user1
                |set:"profile_img":$user1.profile_img
            }
          }
        }
      }
    }
  }

  response = {
    user   : $user1
    company: $companies1|first
    contact: $contacts1
  }
}