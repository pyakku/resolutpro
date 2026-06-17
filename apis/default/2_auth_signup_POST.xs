// Signup and retrieve an authentication token
query "auth/signup" verb=POST {
  api_group = "Default"

  input {
    text name?
    email email?
    text password?
    text l_name? filters=trim
    text lang? filters=trim
    text date_format? filters=trim
    text user_id? filters=trim
    int plan?
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user
  
    precondition ($user == null) {
      error_type = "accessdenied"
      error = "This account is already in use."
    }
  
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        name       : $input.name
        l_name     : $input.l_name
        email      : $input.email
        password   : $input.password
        user_id    : $input.user_id
        profile_img: ""
        language   : $input.lang
        date_format: $input.date_format
        is_admin   : false
        plan       : $input.plan
      }
    } as $user
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 86400
      id = $user.id
    } as $authToken
  }

  response = {authToken: $authToken}
}