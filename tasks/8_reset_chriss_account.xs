task "resetChris'sAccount" {
  stack {
    db.get user {
      field_name = "email"
      field_value = "c.els@btinternet.com"
    } as $user2
  
    db.query user {
      where = ($db.user.email|substr:0:3) == "xyz"
      return = {type: "count"}
    } as $user3
  
    conditional {
      if ($user2|is_empty) {
      }
    
      else {
        db.edit user {
          field_name = "id"
          field_value = $user2.id
          enforce_hidden_fields = false
          data = {
            email: "xyz"|concat:($user3|concat:"@gmail.com":""):""
          }
        } as $user1
      }
    }
  }

  schedule = [{starts_on: 2024-08-27 14:12:33+0000, freq: 3600}]
}