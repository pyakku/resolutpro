query add_invitation verb=POST {
  api_group = "invitations"

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
        inviting_user       : {hidden: false}
        invited_company     : {hidden: false}
        last_email_sent     : {hidden: true}
        invited_company_name: {hidden: false}
      }
    }
  }

  stack {
    db.add invitations {
      enforce_hidden_fields = false
      data = {
        created_at          : "now"
        company             : $input.company
        invited_user        : $input.invited_user
        invited_company     : $input.invited_company
        inviting_user       : $input.inviting_user
        relationship        : $input.relationship
        invited_company_name: $input.invited_company_name
        email               : $input.email
        contact             : $input.contact
        last_email_sent     : now
      }
    } as $invitations_2
  
    db.query invitations {
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
  }

  response = $invitations_1
}