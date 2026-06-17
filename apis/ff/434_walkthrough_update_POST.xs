query walkthrough_update verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text page? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["completed_walkthrough"]
    } as $user1
  
    var.update $user1 {
      value = $user1.completed_walkthrough|safe_array
    }
  
    conditional {
      if ($user1|in:$input.page) {
        db.get user {
          field_name = "id"
          field_value = $auth.id
        } as $user2
      }
    
      else {
        db.edit user {
          field_name = "id"
          field_value = $auth.id
          enforce_hidden_fields = false
          data = {completed_walkthrough: $user1|push:$input.page}
        } as $user2
      }
    }
  }

  response = $user2
}