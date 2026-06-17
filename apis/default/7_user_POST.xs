// Add user record
query user verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "user"
      override = {
        name       : {hidden: false}
        plan       : {hidden: false}
        email      : {hidden: false}
        l_name     : {hidden: false}
        is_admin   : {hidden: false}
        language   : {hidden: false}
        password   : {hidden: true}
        company_id : {hidden: false}
        created_at : {hidden: true}
        date_format: {hidden: false}
        profile_img: {hidden: false}
      }
    }
  }

  stack {
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        name       : $input.name
        l_name     : $input.l_name
        email      : $input.email
        company_id : $input.company_id
        profile_img: $input.profile_img
        language   : $input.language
        date_format: $input.date_format
        is_admin   : $input.is_admin
        plan       : $input.plan
      }
    } as $user
  }

  response = $user
}