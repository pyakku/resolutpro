query getInvitesSentByMe verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.query myPersonaInvites {
      where = $db.myPersonaInvites.invitingUser == $auth.id
      sort = {myPersonaInvites.created_at: "desc"}
      return = {type: "list"}
    } as $myPersonaInvites1
  
    conditional {
      if ($myPersonaInvites1|is_empty) {
        var $return {
          value = []
        }
      }
    
      else {
        var $return {
          value = []
        }
      
        foreach ($myPersonaInvites1) {
          each as $item {
            db.has user {
              field_name = "email"
              field_value = $item.email
            } as $user1
          
            var.update $return {
              value = $return
                |push:($item|set:"signedUp":$user1)
            }
          }
        }
      }
    }
  }

  response = $return
}