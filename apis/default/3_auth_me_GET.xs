// Get the user record belonging to the authentication token
query "auth/me" verb=GET {
  api_group = "Default"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
        "name"
        "l_name"
        "email"
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