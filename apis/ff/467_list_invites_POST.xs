query list_invites verb=POST {
  api_group = "ff"

  input {
    text user_id? filters=trim
    text company? filters=trim
  }

  stack {
    db.query invitations {
      where = $db.invitations.company == $input.company
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
        {
          name : "user"
          input: {user_id: $output.inviting_user}
          as   : "user"
        }
      ]
    } as $invitations_1
  }

  response = $invitations_1
  tags = ["invitations"]
}