query deleteAccountGoogle verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
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
    }
  
    db.query companies {
      where = $db.companies.created_by_user == $user1.id && $db.companies.individual == true && $db.companies.markedForDeletion == false
      return = {type: "list"}
    } as $companies1
  
    precondition (($companies1|is_empty) == false) {
      error_type = "accessdenied"
    }
  
    db.edit companies {
      field_name = "id"
      field_value = $companies1|first|get:"id":null
      enforce_hidden_fields = false
      data = {markedForDeletion: true}
    } as $companies2
  }

  response = {status: "done"}
}