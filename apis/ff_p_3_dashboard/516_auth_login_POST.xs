// Login and retrieve an authentication token
query "auth/login" verb=POST {
  api_group = "ffP3Dashboard"

  input {
    text email?
    text password?
  }

  stack {
    db.get p3DashboardUser {
      field_name = "email"
      field_value = $input.email
      output = ["id", "created_at", "name", "email", "password"]
    } as $p3DashboardUser
  
    precondition ($p3DashboardUser != null) {
      error = "Invalid Credentials."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $p3DashboardUser.password
    } as $pass_result
  
    precondition ($pass_result) {
      error = "Invalid Credentials."
    }
  
    security.create_auth_token {
      table = "p3DashboardUser"
      extras = {}
      expiration = 0
      id = $p3DashboardUser.id
    } as $authToken
  }

  response = {authToken: $authToken}
}