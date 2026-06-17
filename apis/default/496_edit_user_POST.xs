// Get the user record belonging to the authentication token
query editUser verb=POST {
  api_group = "Default"
  auth = "user"

  input {
    text f_name? filters=trim
    text l_name? filters=trim
    text image? filters=trim
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      enforce_hidden_fields = false
      data = {
        name       : $input.f_name
        l_name     : $input.l_name
        profile_img: $input.image
      }
    } as $user1
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
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
    } as $user
  }

  response = $user
}