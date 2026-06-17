query emailExists verb=POST {
  api_group = "Sign Up FF"

  input {
    text? email? filters=trim
  }

  stack {
    conditional {
      if ($input.email == null) {
        var $user1 {
          value = true
        }
      }
    
      else {
        db.has user {
          field_name = "email"
          field_value = $input.email|to_lower
        } as $user1
      }
    }
  }

  response = {exists: $user1}
}