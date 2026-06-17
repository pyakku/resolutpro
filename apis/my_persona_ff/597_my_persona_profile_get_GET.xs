query myPersonaProfileGet verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get contacts {
      field_name = "email"
      field_value = $user1.email
    } as $contacts1
  
    !var.update $user1 {
      value = $user1
        |set:"phone":$var.contacts1.phone_number??""
    }
  
    db.get locum {
      field_name = "user_id"
      field_value = $auth.id
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.regulator_id}
          as   : "_regulator"
        }
      ]
    } as $locum1
  
    var.update $user1 {
      value = $user1
        |set:"phone":$var.contacts1.phone_number??""
        |set:"city":$var.locum1.city??""
        |set:"regulator":$var.locum1._regulator.name??""
        |set:"regulatorMembershipNumber":$var.locum1.membershipNumber??""
        |set:"role":$var.locum1.role??""
        |set:"active":$var.locum1.active??false
    }
  
    !conditional {
      if ($input.isWeb) {
        conditional {
          if ($user1.profile_img|istarts_with:"data") {
            var.update $user1 {
              value = $user1
                |set:"profile_img":$user1.profile_img
            }
          }
        
          else {
            var.update $user1 {
              value = $user1
                |set:"profile_img":("data:image/jpeg;base64,"|concat:$user1.profile_img:"")
            }
          }
        }
      }
    
      else {
        conditional {
          if ($user1.profile_img|istarts_with:"data") {
            var.update $user1 {
              value = $user1
                |set:"profile_img":($user1.profile_img|split:","|last)
            }
          }
        
          else {
            var.update $user1 {
              value = $user1
                |set:"profile_img":$user1.profile_img
            }
          }
        }
      }
    }
  }

  response = $user1
}