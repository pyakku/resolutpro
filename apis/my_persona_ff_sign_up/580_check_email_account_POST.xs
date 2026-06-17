query checkEmailAccount verb=POST {
  api_group = "myPersonaFFSignUp"

  input {
    text email? filters=trim
  }

  stack {
    db.has user {
      field_name = "email"
      field_value = $input.email|to_lower
    } as $user1
  
    conditional {
      if ($user1) {
        db.get user {
          field_name = "email"
          field_value = $input.email|to_lower
        } as $user2
      
        db.query companies {
          where = $db.companies.created_by_user == $user2.id && $db.companies.individual == true
          return = {type: "list"}
        } as $companies1
      
        conditional {
          if ($companies1|is_empty) {
            var $individualAccount {
              value = false
            }
          }
        
          else {
            var $individualAccount {
              value = true
            }
          }
        }
      }
    
      else {
        var $individualAccount {
          value = false
        }
      }
    }
  }

  response = {
    userExists       : $user1
    individualAccount: $individualAccount
  }
}