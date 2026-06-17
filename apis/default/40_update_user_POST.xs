query update_user verb=POST {
  api_group = "Default"

  input {
    int id?
    text name? filters=trim
    text l_name? filters=trim
    text user_id? filters=trim
    text profile_img? filters=trim
    text date_format? filters=trim
    bool is_admin?=false
    email email?
    password password? {
      visibility = "internal"
    }
  
    text language? filters=trim
  }

  stack {
    db.edit user {
      field_name = "user_id"
      field_value = $input.user_id
      enforce_hidden_fields = false
      data = {
        name       : $input.name
        l_name     : $input.l_name
        email      : $input.email
        password   : $input.password
        profile_img: $input.profile_img
        language   : $input.language
        date_format: $input.date_format
        is_admin   : $input.is_admin
      }
    
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
      ]
    } as $user_1
  }

  response = $user_1
}