query add_invitation verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    dblink {
      table = "invitations"
      override = {
        email               : {hidden: false}
        company             : {hidden: false}
        contact             : {hidden: false}
        created_at          : {hidden: true}
        invited_user        : {hidden: false}
        relationship        : {hidden: false}
        inviting_user       : {hidden: true}
        invited_company     : {hidden: false}
        last_email_sent     : {hidden: true}
        invited_company_name: {hidden: false}
      }
    }
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.add invitations {
      enforce_hidden_fields = false
      data = {
        created_at          : "now"
        company             : $input.company
        invited_user        : $input.invited_user
        invited_company     : $input.invited_company
        inviting_user       : $user1.id
        relationship        : $input.relationship
        invited_company_name: $input.invited_company_name
        email               : $input.email
        contact             : $input.contact
        last_email_sent     : now
        accepted            : $input.accepted
        last_email_res      : $input.last_email_res
      }
    } as $invitations_2
  
    db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    !db.query invitations {
      where = $db.invitations.inviting_user == $input.inviting_user
      sort = {invitations.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.company}
          as   : "company"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.invited_company}
          as   : "invited_company"
        }
        {
          name : "relationships"
          input: {relationships_id: $output.relationship}
          as   : "relationship"
        }
      ]
    } as $invitations_1
  
    db.get user {
      field_name = "id"
      field_value = $user1.id
    } as $invitingUSerDetails
  
    api.request {
      url = $env.emailBase
        |concat:"invite.php?email=":""
        |concat:($input.email
          |concat:("&client="
            |concat:($companies1.Company_Name
              |concat:("&f_name="
                |concat:($input.contact
                  |concat:("&inviting_user="
                    |concat:($invitingUSerDetails.name
                      |concat:("%20"
                        |concat:$invitingUSerDetails.l_name:""
                      ):""
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
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $invitations_2
  tags = ["invitations"]
}