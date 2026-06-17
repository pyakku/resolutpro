// Edit user record
query "user/{user_id}" verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "user"
      override = {
        name       : {hidden: false}
        email      : {hidden: false}
        l_name     : {hidden: false}
        user_id    : {hidden: false}
        is_admin   : {hidden: false}
        language   : {hidden: false}
        password   : {hidden: false}
        company_id : {hidden: false}
        created_at : {hidden: true}
        date_format: {hidden: false}
        profile_img: {hidden: false}
      }
    }
  
    int id?
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      enforce_hidden_fields = false
      data = {
        name       : $input.name
        l_name     : $input.l_name
        email      : $input.email
        password   : $input.password
        user_id    : $input.user_id
        profile_img: $input.profile_img
        language   : $input.language
        date_format: $input.date_format
        is_admin   : $input.is_admin
      }
    
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
      ]
    } as $user
  }

  response = $user
}