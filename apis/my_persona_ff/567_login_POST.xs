query login verb=POST {
  api_group = "myPersonaFF"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email|to_lower
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
  
    precondition (($user1|is_empty) == false) {
      error_type = "accessdenied"
      error = "User does not exist."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $user1.password
    } as $correct
  
    precondition ($correct) {
      error_type = "accessdenied"
      error = "Incorrect Password"
    }
  
    db.query companies {
      where = $db.companies.created_by_user == $user1.id && $db.companies.individual == true && $db.companies.markedForDeletion == false
      return = {type: "list"}
    } as $companies1
  
    precondition (($companies1|is_empty) == false) {
      error_type = "accessdenied"
      error = "mypersona account not found."
    }
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 0
      id = $user1.id
    } as $authToken
  }

  response = {authToken: $authToken}
}