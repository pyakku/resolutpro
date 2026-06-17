query generate_markel_link verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.get locum {
      field_name = "user_id"
      field_value = $auth.id
    } as $locum1
  
    db.get "myPersona Roles" {
      field_name = "role"
      field_value = $locum1.role
    } as $myPersona_Roles1
  }

  response = {
    url: ($var.myPersona_Roles1.white_collar??false)?$env.markel_white_collar_link:$env.markel_trades_link
  }
}