query getInvitesmyPersonaAll verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query myPersonaInvites {
      sort = {myPersonaInvites.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.invitingUser}
          as    : "invitingUser"
        }
      ]
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