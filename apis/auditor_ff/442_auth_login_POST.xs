// Login and retrieve an authentication token
query "auth/login" verb=POST {
  api_group = "Auditor FF"

  input {
    text email?
    text password?
  }

  stack {
    precondition (($input.email|is_empty) != true) {
      error = "Please enter your email."
    }
  
    db.get auditor {
      field_name = "email"|to_lower
      field_value = $input.email|to_lower
      output = ["id", "created_at", "name", "email", "password"]
    } as $auditor
  
    precondition ($auditor != null) {
      error = "This email ID is not registered. Please check the email you have entered."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $auditor.password
    } as $pass_result
  
    precondition ($pass_result) {
      error = "You have entered a wrong password. Please try again."
    }
  
    security.create_auth_token {
      table = "auditor"
      extras = {}
      expiration = 0
      id = $auditor.id
    } as $authToken
  }

  response = {authToken: $authToken}
}