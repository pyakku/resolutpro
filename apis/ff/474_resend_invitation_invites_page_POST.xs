query resend_invitationInvitesPage verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int inviteID?
  }

  stack {
    db.get invitations {
      field_name = "id"
      field_value = $input.inviteID
    } as $invitations1
  
    db.get companies {
      field_name = "id"
      field_value = $invitations1.company
    } as $companies1
  
    db.get user {
      field_name = "id"
      field_value = $invitations1.inviting_user
    } as $user1
  
    api.request {
      url = $env.emailBase
        |concat:"invite.php?email=":""
        |concat:($invitations1.email
          |concat:("&client="
            |concat:($companies1.Company_Name
              |concat:("&f_name="
                |concat:($invitations1.contact
                  |concat:("&inviting_user="
                    |concat:($user1.name
                      |concat:("%20"|concat:$user1.l_name:""):""
                    ):""
                  ):""
                ):""
              ):""
            ):""
          ):""
        ):""
      method = "GET"
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.edit invitations {
      field_name = "id"
      field_value = $input.inviteID
      enforce_hidden_fields = false
      data = {last_email_sent: now, last_email_res: $api1}
    } as $invitations2
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $email_log1
  tags = ["invitations"]
}