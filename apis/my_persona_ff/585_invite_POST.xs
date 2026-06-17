query invite verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    text name? filters=trim
    text email? filters=trim
    text lastName? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    api.request {
      url = $env.emailBase|concat:"myPersonaInvite.php":""
      method = "POST"
      params = {}
        |set:"name":$input.name
        |set:"email":$input.email
        |set:"inviter":$user1.name
        |set:"lastName":$input.lastName
        |set:"inviterLastName":$user1.l_name
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  
    db.query myPersonaInvites {
      where = $db.myPersonaInvites.email == ($input.email|to_lower) && $db.myPersonaInvites.invitingUser == $auth.id
      return = {type: "exists"}
    } as $myPersonaInvites1
  
    conditional {
      if ($myPersonaInvites1) {
        db.query myPersonaInvites {
          where = $db.myPersonaInvites.email == ($input.email|to_lower) && $db.myPersonaInvites.invitingUser == $auth.id
          return = {type: "single"}
        } as $myPersonaInvites1
      
        db.edit myPersonaInvites {
          field_name = "id"
          field_value = $myPersonaInvites1.id
          enforce_hidden_fields = false
          data = {
            name     : $input.name
            lastName : $input.lastName
            emailSent: $myPersonaInvites1.emailSent|push:now
          }
        } as $myPersonaInvites2
      }
    
      else {
        db.add myPersonaInvites {
          enforce_hidden_fields = false
          data = {
            created_at  : "now"
            name        : $input.name
            lastName    : $input.lastName
            email       : $input.email|to_lower
            invitingUser: $auth.id
            emailSent   : now
          }
        } as $myPersonaInvites3
      }
    }
  
    api.request {
      url = $env.emailBase
        |concat:"myPersonaInviteEmailToInviter.php":""
      method = "POST"
      params = {}
        |set:"name":$input.name
        |set:"lastName":$input.lastName
        |set:"email":$input.email
        |set:"inviter":$user1.name
        |set:"inviterEmail":$user1.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $user1
}