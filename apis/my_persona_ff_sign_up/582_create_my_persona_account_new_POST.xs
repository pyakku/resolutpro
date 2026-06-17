query createMyPersonaAccountNew verb=POST {
  api_group = "myPersonaFFSignUp"

  input {
    text name? filters=trim
    text email? filters=trim
    text password? filters=trim
    text lastName? filters=trim
  }

  stack {
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        name      : $input.name
        l_name    : $input.lastName
        email     : $input.email|to_lower
        password  : $input.password
      }
    } as $user1
  
    db.add companies {
      enforce_hidden_fields = false
      data = {
        created_at     : "now"
        Company_Name   : $input.name|concat:$input.lastName:" "
        email          : $input.email
        created_by_user: $user1.id
        individual     : true
      }
    } as $companies1
  
    db.has contacts {
      field_name = "email"
      field_value = $input.email|to_lower
    } as $contactExists
  
    conditional {
      if ($contactExists) {
        db.get contacts {
          field_name = "email"
          field_value = $input.email|to_lower
        } as $contacts1
      
        db.edit contacts {
          field_name = "id"
          field_value = $contacts1.id
          enforce_hidden_fields = false
          data = {
            name      : $input.name
            l_name    : $input.lastName
            created_by: $companies1.id
            approved  : true
            code      : ""
          }
        } as $contacts2
      }
    
      else {
        db.add contacts {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            name      : $input.name
            l_name    : $input.lastName
            email     : $input.email|to_lower
            created_by: $companies1.id
            approved  : true
          }
        } as $contacts2
      }
    }
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 0
      id = $user1.id
    } as $authToken
  
    api.request {
      url = $env.emailBase|concat:"myPersonaOnboard.php":""
      method = "POST"
      params = {}
        |set:"email":$input.email
        |set:"name":$input.name
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.query myPersonaInvites {
      where = $db.myPersonaInvites.email == ($input.email|to_lower)
      return = {type: "list"}
      addon = [
        {
          name : "user"
          input: {user_id: $output.invitingUser}
          as   : "invitingUser"
        }
      ]
    } as $myPersonaInvites1
  
    conditional {
      if ($myPersonaInvites1|is_empty) {
      }
    
      else {
        foreach ($myPersonaInvites1) {
          each as $item {
            api.request {
              url = $env.emailBase
                |concat:"myPersonaInviteeHasJoined.php":""
              method = "POST"
              params = {}
                |set:"email":$item.email
                |set:"name":$item.name
                |set:"inviter":$item.invitingUser.name
                |set:"inviter_email":$item.invitingUser.email
              headers = []
                |push:"Content-Type: application/json"
            } as $api1
          }
        }
      }
    }
  }

  response = {
    authToken: $authToken
    contact  : $contacts2
    company  : $companies1
    user     : $user1
  }
}