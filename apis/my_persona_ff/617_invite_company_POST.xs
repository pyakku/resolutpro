query inviteCompany verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    text invitee? filters=trim
    text email? filters=trim
    text company? filters=trim
    text inviteeLastName? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    api.request {
      url = $env.emailBase
        |concat:"myPersonaShareDocumentInvitationToP3.php":""
      method = "POST"
      params = {}
        |set:"inviteeFirstName":$input.invitee
        |set:"firstName":$user1.name
        |set:"lastName":$user1.l_name
        |set:"email":$input.email
        |set:"company":$input.company
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add myPersonaInvites {
      enforce_hidden_fields = false
      data = {
        created_at  : "now"
        name        : $input.invitee
        lastName    : $input.inviteeLastName
        email       : $input.email
        invitingUser: $auth.id
        emailSent   : now
      }
    } as $myPersonaInvites1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $api1
}