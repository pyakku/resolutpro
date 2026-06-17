query business_dev_edit_user verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "user"
      override = {
        name        : {hidden: false}
        plan        : {hidden: true}
        email       : {hidden: true}
        l_name      : {hidden: false}
        user_id     : {hidden: true}
        is_admin    : {hidden: true}
        language    : {hidden: true}
        password    : {hidden: true}
        created_at  : {hidden: true}
        date_format : {hidden: true}
        profile_img : {hidden: false}
        business_dev: {hidden: true}
      }
    }
  
    text id? filters=trim
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        name       : $input.name
        l_name     : $input.l_name
        profile_img: $input.profile_img
      }
    } as $user_1
  }

  response = $user_1
}