query myInvites verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query invitations {
      where = $db.invitations.inviting_user == $auth.id && $db.invitations.company == $input.company && $db.invitations.invited_user == 0
      sort = {invitations.last_email_sent: "desc"}
      return = {type: "list"}
    } as $invitations1
  
    foreach ($invitations1) {
      each as $item {
        db.has user {
          field_name = "email"
          field_value = $item.email
        } as $user1
      
        conditional {
          if ($user1) {
            db.edit invitations {
              field_name = "id"
              field_value = $item.id
              enforce_hidden_fields = false
              data = {accepted: true}
            } as $invitations2
          }
        
          else {
            db.edit invitations {
              field_name = "id"
              field_value = $item.id
              enforce_hidden_fields = false
              data = {accepted: false}
            } as $invitations2
          }
        }
      }
    }
  
    db.query invitations {
      where = $db.invitations.inviting_user == $auth.id && $db.invitations.company == $input.company && $db.invitations.invited_user == 0
      sort = {invitations.last_email_sent: "desc"}
      return = {type: "list"}
    } as $invitations1
  }

  response = $invitations1
  tags = ["invitations"]
}