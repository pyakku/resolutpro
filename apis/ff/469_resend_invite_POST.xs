query resend_invite verb=POST {
  api_group = "ff"

  input {
    text invite_id? filters=trim
    text email? filters=trim
    text company? filters=trim
  }

  stack {
    db.get invitations {
      field_name = "id"
      field_value = $input.invite_id
    } as $invitations_1
  
    conditional {
      if ($invitations_1.invited_user == 0 || $invitations_1.invited_user == null) {
        db.edit invitations {
          field_name = "id"
          field_value = $input.invite_id
          enforce_hidden_fields = false
          data = {email: $input.email, last_email_sent: now}
          addon = [
            {
              name : "companies"
              input: {companies_id: $output.company}
              as   : "company"
            }
          ]
        } as $invitations_2
      
        function.run invite_email {
          input = {
            vendor              : false
            invited_company_name: $invitations_2.invited_company_name
            email               : $input.email
            contact             : $invitations_2.contact
            inviting_company    : $invitations_2.company.Company_Name
            code                : ""
          }
        } as $func_1
      
        db.edit invitations {
          field_name = "id"
          field_value = $input.invite_id
          enforce_hidden_fields = false
          data = {email: $input.email, last_email_res: $func_1}
        } as $invitations_4
      }
    
      else {
        db.edit invitations {
          field_name = "id"
          field_value = $input.invite_id
          enforce_hidden_fields = false
          data = {email: $input.email, last_email_sent: now}
          addon = [
            {
              name : "user"
              input: {user_id: $output.invited_user}
              as   : "invited_user"
            }
            {
              name : "companies"
              input: {companies_id: $output.company}
              as   : "company"
            }
          ]
        } as $invitations_2
      
        function.run invite_email {
          input = {
            vendor              : true
            inviting_company    : $invitations_2.company.Company_Name
            code                : $invitations_2.invited_user.name
            invited_company_name: $invitations_2.invited_company_name
            email               : $input.email
            contact             : $invitations_2.contact
            accepted            : false
            last_email_res      : {}
          }
        } as $func_1
      
        db.edit invitations {
          field_name = "id"
          field_value = $input.invite_id
          enforce_hidden_fields = false
          data = {last_email_res: $func_1}
        } as $invitations_5
      
        db.edit user {
          field_name = "id"
          field_value = $invitations_1.invited_user
          enforce_hidden_fields = false
          data = {email: $input.email}
        } as $user_1
      }
    }
  
    db.query invitations {
      where = $db.invitations.company == $input.company
      sort = {invitations.last_email_sent: "desc"}
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
        {
          name : "user"
          input: {user_id: $output.inviting_user}
          as   : "user"
        }
      ]
    } as $invitations_3
  }

  response = $invitations_3
  tags = ["invitations"]
}