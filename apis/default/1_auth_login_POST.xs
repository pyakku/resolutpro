// Login and retrieve an authentication token
query "auth/login" verb=POST {
  api_group = "Default"

  input {
    email email?
    text password?
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email|to_lower
      output = ["id", "created_at", "name", "email", "password"]
    } as $user
  
    precondition ($user != null) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $user.password
    } as $pass_result
  
    conditional {
      if ($pass_result == false && ($user|count) != 0) {
        db.add logs {
          enforce_hidden_fields = false
          data = {
            created_at  : "now"
            companies_id: "0"
            user_id     : $user.id
            action      : "Failed Login"
          }
        } as $logs_1
      }
    }
  
    precondition ($pass_result) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 86400
      id = $user.id
    } as $authToken
  }

  response = {authToken: $authToken}
}